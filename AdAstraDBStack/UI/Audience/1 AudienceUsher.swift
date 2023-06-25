//
//  File.swift
//  
//
//  Created by cms on 1/6/22.
//

/*
 AudienceUsher -- coordinates updates & monitoring
 Attendee -- live presence of project observers-- at the UISCene level
 Guestbook -- list of devices that ever attended
 
 */

import Foundation
import CoreData
import AdAstraExtensions
#if os(iOS)
#if FALSE //DeviceKit exclude
import DeviceKit
#endif
#elseif os(macOS)
//import AdAstraBridgingByMask  <- 2023-06-25 need to reenable
#endif
// #if CaleoShareExtension
// import DeviceKit
// #endif

public class AudienceUsher: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   static let DelayBetweenUpdatingMyTimestamp: TimeInterval = 60
   static let MaximumIntervalForAttendeeUpdate: TimeInterval =  60 * 10 // 10 minutes
   static let MaximumIntervalForUpdateWithForcedSave: TimeInterval = 60 * 5 // 10 minutes // should always be smaller than 'MaximumIntervalForAttendeeUpdate'
   // 60 * 60 // one hour
   static let AttendanceUpdateFastInterval: TimeInterval = 1
   static let AttendanceUpdateDefaultInterval: TimeInterval = 60
   
   override public class func llogPrefix() -> String? {"🏟"}
   
   var parentProjectObjectID: NSManagedObjectID
   var context: NSManagedObjectContext

   private var myAttendeeRecord: AttendeeEntityProtocol?
	private var myGuestbookEntry: GuestbookEntryEntityProtocol?
   

   var otherAttendeesFRC: NSFetchedResultsController<AttendeeEntityProtocol>? {
      // let fetchRequest: NSFetchRequest<AudienceMember> = AudienceMember.fetchRequest()
      let fetchRequest = NSFetchRequest<AttendeeEntityProtocol>(entityName: Self.AttendeeEntityName)
      fetchRequest.sortDescriptors = [
         NSSortDescriptor(key: #keyPath(AttendeeEntityProtocol.lastObservationTimestamp), ascending: false)
      ]
      fetchRequest.predicate = NSCompoundPredicate(
         type: .and,
         subpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(AttendeeEntityProtocol.parentProject), self.parentProjectObjectID),
            NSPredicate(format: "%K != %@", "appInstallID", Self.appInstallID as CVarArg)
         ])
      
      let fetchedResultsController = NSFetchedResultsController<AttendeeEntityProtocol>(
         fetchRequest: fetchRequest,
         managedObjectContext: self.context,
         sectionNameKeyPath: nil,
         cacheName: nil)
      fetchedResultsController.delegate = self
      
      // do {
      //    try fetchedResultsController.performFetch()
      // } catch {
      //    llog("🛑 fetch failed: \(error)")
      // }
      return fetchedResultsController
   }
   
   @Published var audienceIsObserving: Bool = false
   var otherAttendeesCount: Int = 0 {
      didSet {
         llog("🔄 updated other audience count: \(self.otherAttendeesCount.description) ")
         
         let newObservingValue = self.otherAttendeesCount > 0 // test whether other audience members exist
         if audienceIsObserving != newObservingValue { audienceCountDidChange(to: newObservingValue) }
      }
   }
   func audienceCountDidChange(to newObservingValue: Bool) {
      
      audienceIsObserving = newObservingValue
      
      if self.audienceIsObserving {
         fastSavingHeartbeat.start()
      } else {
         fastSavingHeartbeat.pause()
      }

   }
   
   static var appInstallID: UUID = UUID()
   
   // INIT

   public init(stack: ProjectsDBStack, parentProjectObjectID: NSManagedObjectID) {
      self.parentProjectObjectID = parentProjectObjectID
      self.context = stack.newBackgroundContext(named: "AudienceUsher")
      // self.context = ProjectsDBStack.shared.newBackgroundContext(named: "AudienceUsher")
      super.init()
      
      // Check that appInstallID is set (happens only on first launch after new device install
      // (should stay same across device restores/upgrades, but change if app data deleted, so actually a unique install identifier)
      if let foundAppInstallIDstring = UserDefaults.standard.object(forKey: "AudienceUsherAppInstallID") as? String,
         let foundAppInstallIDstringUUID: UUID = UUID(uuidString: foundAppInstallIDstring) {
         Self.appInstallID = foundAppInstallIDstringUUID
      } else {
         // new install, set the value
         UserDefaults.standard.set(Self.appInstallID.uuidString, forKey: "AudienceUsherAppInstallID")
      }
      
      attendanceHeartbeat.start()
      signGuestBook()
      
      NotificationCenter.default.addObserver(self, selector: #selector(recordLastContetextSave), name: NSManagedObjectContext.didSaveObjectsNotification, object: ProjectsDBStack.shared?.rootBackgroundContext)
      // monitoring 'rootBackgroundContext' because this member's latest timestamp updates are saved only up into the 'rootBackgroundContext', assuming that 'rootBackgroundContext' will commit a save soon. If 'lastContextSave' gets too old, then this instance will force a save
   }
   deinit {
      self.cancelAttendance()
   }
   
   var lastRootContextSave: DispatchTime = DispatchTime(uptimeNanoseconds: 0) // distant past
   @objc func recordLastContetextSave(){
      lastRootContextSave = .now()
   }
   
   func updateAttendanceTimestamp() {
      context.performWithoutWaiting{[weak self] context in
         guard let self = self else { return }
         
         let membership = self.myAttendeeRecord ?? self.newAttendee(into: context)
         membership.lastObservationTimestamp = Date(timeIntervalSinceNow: 0)
         if self.myAttendeeRecord == nil { self.myAttendeeRecord = membership }
         try? context.save() // local save, let the rootBackgroundContext commit on next save
         
         // if time since last context save was substainally more than the MaximumDurationSinceLastObservation, then force context save
         if self.lastRootContextSave + Self.MaximumIntervalForUpdateWithForcedSave < DispatchTime.now() { self.context.saveContexts() }
      }
   }
   
   // heartbeat to update attendance timestamp frequently
	lazy var attendanceHeartbeat = AdAstraHeartbeat(interval:
																										Self.AttendanceUpdateDefaultInterval,
																									beatNoMoreThanInterval: true,
																									startOnAwake: false,
																									pauseWhileBackgrounded: true,
																									beatWhenBackgrounded: false,
																									beatWhenForegrounded: true,
																									name: "AttendenceMemberPresence"
	){[weak self] in
      guard let self = self else { return }
      self.updateAttendanceTimestamp()
   }
   
	lazy var fastSavingHeartbeat = AdAstraHeartbeat(interval: Self.AttendanceUpdateFastInterval,
																									beatNoMoreThanInterval: false,
																									startOnAwake: false,
																									pauseWhileBackgrounded: true,
																									beatWhenBackgrounded: true,
																									beatWhenForegrounded: false,
																									name: "AttendenceFastSaving"
	){[weak self] in
      guard let self = self else { return }
      ProjectsDBStack.shared?.saveAllContexts()
   }
   
   
   
   func cancelAttendance(){
      // self.attendanceHeartbeat.pause()
      guard let membership = self.myAttendeeRecord else { return }
      context.performWithoutWaiting{ context in
         membership.delete()
         context.saveContexts()
      }
   }
   
   func cleanUpAnyAbandonedAttendees(){
      context.performWithoutWaiting{ [weak self] context in
         guard let self = self else { return }
         var earliestMemberTimestamp: Date = Date.distantPast
         for attendee in self.otherAttendeesFRC?.fetchedObjects ?? [AttendeeEntityProtocol]() {
            if let memberTimestamp = attendee.lastObservationTimestamp {
               if memberTimestamp < Date() - Self.MaximumIntervalForAttendeeUpdate {
                  self.llog("will delete for being abandoned:")
                  self.llog("\(attendee.debugDescription)")
                  // context.delete(member)
                  attendee.delete()
               } else {
                  if memberTimestamp < earliestMemberTimestamp {
                     earliestMemberTimestamp = memberTimestamp
                  }
               }
            } else {
               // self.context.delete(member)
               attendee.delete()
               self.llog("deleted for being nil")
            }
         }
         let nextCheckInterval = Date().timeIntervalSince(earliestMemberTimestamp) + 1 // one second longer
         self.cleanupHeartbeat.scheduleNextBeat(
            for: TimeInterval(nextCheckInterval)
         )
      }
   }
	lazy var cleanupHeartbeat = AdAstraHeartbeat( interval: Self.MaximumIntervalForAttendeeUpdate,
																								beatNoMoreThanInterval: true,
																								startOnAwake: false,
																								pauseWhileBackgrounded: true,
																								beatWhenBackgrounded: false,
																								beatWhenForegrounded: true,
																								name: typeName + "_Cleanup"

	){[ weak self] in
      guard let self = self else { return }
      self.cleanUpAnyAbandonedAttendees()
   }
   
   // changes happend to other audience members.  This member is not included in FRC
   public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      otherAttendeesCount = controller.fetchedObjects?.count ?? 0
      
   }
   
   static var AttendeeEntityName: String { "Attendee" }
   func newAttendee(into context: NSManagedObjectContext) -> AttendeeEntityProtocol {
      let attendee = NSEntityDescription.insertNewObject(
         forEntityName: AudienceUsher.AttendeeEntityName,
         into: context) as! AttendeeEntityProtocol
      attendee.parentProject = context.object(with: parentProjectObjectID) as? AudienceParentProjectProtocol
      attendee.signedGuestbookEntry = myGuestbookEntry
      return attendee
   }
   
   
}


//Mark: GuestBook

extension AudienceUsher {
   static var GuestbookEntryEntityName: String { "GuestbookEntry" }
   
   func buildGuestBookEntryFetchRequest() ->  NSFetchRequest<GuestbookEntryEntityProtocol> {
      let request = NSFetchRequest<GuestbookEntryEntityProtocol>(entityName: Self.GuestbookEntryEntityName)
      request.sortDescriptors = [
         NSSortDescriptor(key: #keyPath(GuestbookEntryEntityProtocol.mostRecentAccessTimestamp), ascending: true) // latest at end
      ]
      request.predicate = NSCompoundPredicate(
         type: .and,
         subpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(GuestbookEntryEntityProtocol.appInstallID), Self.appInstallID as CVarArg),
         ])
      return request
   }
   
   func newGuestbookEntry(into context: NSManagedObjectContext) -> GuestbookEntryEntityProtocol {
      let newEntry = NSEntityDescription.insertNewObject(
         forEntityName: AudienceUsher.GuestbookEntryEntityName,
         into: context) as! GuestbookEntryEntityProtocol
      newEntry.parentProject = context.object(with: parentProjectObjectID) as? AudienceParentProjectProtocol

      newEntry.appInstallID = Self.appInstallID
      if #available(macOS 12.0, iOS 15, *) {
         newEntry.cloudKitUser_PersonNameComponents_Store = try? JSONEncoder().encode(AACollaborationViewModel.CurrentUserParticipantNameComponents)
         newEntry.cloudKitUserID = AACollaborationViewModel.CurrentUserParticipantUniqueID
      }
#if FALSE //DeviceKit exclude
		 newEntry.deviceIdentifier = Device.identifier
#endif
      newEntry.firstAccessTimestamp = Date()
      
      
      return newEntry
   }

   func signGuestBook(){
      
      // try to get existing entries
      guard let myGuestBookEntries: [GuestbookEntryEntityProtocol] = try? context.fetch(buildGuestBookEntryFetchRequest()) else { return }
      
      if myGuestBookEntries.count > 1 {
      // found prior entries, log
         llog("unexpectedly found \(myGuestBookEntries.count) myGuestBookEntries, will use only the last")
      }
      
      // Use most recent entry or create new entry
      myGuestbookEntry = myGuestBookEntries.last ?? newGuestbookEntry(into: context)
      // make updates
      // myGuestbookEntry?.updateRecents(in: myGuestbookEntry)
      if let entry = myGuestbookEntry {
         Self.updateRecents(in: entry)
      }
      // context.saveContexts()
      
      
      
   }
   
   static func updateRecents(in entry: GuestbookEntryEntityProtocol) {
      entry.mostRecentAccessTimestamp = Date()
      entry.mostRecentDBVersion = ""
      entry.mostRecentCaleoAppVerion = ""
   }

}


