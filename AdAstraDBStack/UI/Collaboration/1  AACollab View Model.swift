//
//       Collaboration Actions.swift
//       Collaboration Actions
//
//  Created by cms on 10/19/21.
//

// import UIKit
import Foundation
// import CloudKit
import CoreData
//#if !DebugWithoutCloudKit
import CloudKit
//#endif
import AdAstraExtensions
//import AdAstraBridgingByShim   <- 2023-06-25 need to reenable
import SwiftUI

#if true //os(iOS)

@available(macCatalyst 15, iOS 15, macOS 12, *)
open class AACollaborationViewModel: NSObject, ObservableObject {
   
   // var sharedStack: ProjectsDBStack
   public var projectListing: AAProjectListingProtocol
   
   lazy var cloudKitSharingControllerDelegate =
   AACollaborationViewModel.CloudKitSharingControllerDelegate(self)
   
   
   // public init(sharedStack: ProjectsDBStack, projectListing: AAProjectListingProtocol) {
   // self.sharedStack = sharedStack
   public init(projectListing: AAProjectListingProtocol) {
      self.projectListing = projectListing
      
      super.init()
      
      fetchExistingCKShare()
      refreshParticipants()
      
   }
   
   lazy var ckContainer = CKContainer(identifier: ProjectsDBStack.CloudKitContainerIdentifier)
   
   @Published
   var ckShare: CKShare? // assigned in fetchExistingCKShare() or when addCollaborator() creates the new share
   
   @Published
   public var participants: [Ladder_ShareParticipant] = [Ladder_ShareParticipant]()
   
   public static var CurrentUserParticipant: CKShare.Participant?
   public static var CurrentUserParticipantUniqueID: String? { CurrentUserParticipant?.uniqueID }
   public static var CurrentUserParticipantNameComponents: PersonNameComponents? { CurrentUserParticipant?.userIdentity_.nameComponents }
   public static var CurrentUserParticipantDisplayName: String? { CurrentUserParticipant?.displayName }
// other extensions can reference these static vars for quick access to CKShare data
   
   // checks if a ckShare exists and saves it
   
   // call this method periodically to keep the cached ckShare refreshed
   @discardableResult
   func fetchExistingCKShare() -> CKShare? {
		 let ckShares: [CoreData.NSManagedObjectID: CKShare] = ( try? ProjectsDBStack.shared?.container.fetchShares(matching: [projectListing.objectID]) ) ?? [:]
      
      if let ckShare = ckShares[projectListing.objectID] {
         llog("found a ckShare")
         self.ckShare = ckShare
      } else {
         llog("failed to get a ckShare")
         self.ckShare = nil
      }
      return self.ckShare
      
      ToDo(.moderateImportance, "Add CKQuerySubscription for the ckShare record")
      // this subscription is needed to get updates with ckShare changes, (particularly when owner unshares--to close the project). Can add visual notification when participant accepts/departs a share
   }
   
   // checks if a ckShare exists, and if not then will attempt to create it
   func attemptLoadingCKShare() -> CKShare? {
      
      // check if share exists
      if let ckShare = fetchExistingCKShare() { return ckShare }
      
      // no CKShare found, will attempt to create it
      guard let ckRecord = ProjectsDBStack.shared?.container.record(for: self.projectListing.objectID) else { return nil }
      
      // CKShare(recordZoneID: ckRecord.recordID.zoneID)
      
      let ckShare = CKShare(rootRecord: ckRecord)
      self.ckShare = ckShare
      
      llog(ckShare.recordID.zoneID.zoneName)
      llog(ckRecord.recordID.zoneID.zoneName)
      if ckShare.recordID.zoneID == ckRecord.recordID.zoneID {
         llog("!!! zones are the same in loadingCKShare")
      } else {
         llog ("-_- zones are different in loadingCKShare")
      }
      
      let modifyOp = CKModifyRecordsOperation(recordsToSave: [ckRecord, ckShare])
      ckContainer.privateCloudDatabase.add(modifyOp)
      return self.ckShare
      
      
   }
   
   
   var isShared: Bool { projectListing.isShared }
   
   var userIsOwner: Bool { projectListing.userIsOwner }
   
   lazy var collaboratorColors: [AdAstraColor] = {
      
      if false {
         let segments = ( 60 / AdAstraColor.CollaboratorColors.count)
         
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "s"
         let secondString = dateFormatter.string(from: projectListing.createdTimestamp ?? Date.init(timeIntervalSinceNow: 0))
         let second = Int(secondString) ?? 0
         
         let initialSegment = second / segments
         
         let result = second.quotientAndRemainder(dividingBy: segments)
         
         let initialIndex = result.quotient
      } else {
         return AdAstraColor.CollaboratorColors
      }
   }()
   public func colorForCollaboratorID(_ collaboratorID: String) -> Color? {
      let index = participants.firstIndex{
         $0.uniqueID == collaboratorID
      }
      if let aaColor: AdAstraColor = collaboratorColors[wrapAroundForIndex: index] {
         return aaColor.system
      }
      return nil
   }
   
   func addCollaborator( with permissions: CloudKitSharingControllerDelegate.SharingPermission? = nil ){
      self.cloudKitSharingControllerDelegate?.addCollaborator(with: permissions)
   }
   func deleteShare() {
      self.cloudKitSharingControllerDelegate?.deleteShare()
   }
   
   open func projectListingThumbnailIcon() -> UINSImage? { return nil } // overridable for providing project's icon
   
   func inspectorDidAppear(){
      fetchExistingCKShare() // keep cached ckShare updated
   }
}



@available(macCatalyst 15, iOS 15, macOS 12, *)
extension AACollaborationViewModel {

	func refreshParticipants(){
		if AdAstraCollaborationDebug.feature.showFakeCollaboratorsList ?? false {
			self.participants = fakeCollaborators
			return
		}
		if let share = ckShare {
			self.participants = share.participants
			Self.CurrentUserParticipant = share.currentUserParticipant
		} else {
			// no share record exists
			self.participants = [Ladder_ShareParticipant]() // empty list
         Self.CurrentUserParticipant = nil
		}
	}

	var fakeCollaborators: [CollaboratorPlaceHolder] {

		var participants: [CollaboratorPlaceHolder] = [CollaboratorPlaceHolder]()
		for i in 1...5 {
			participants.append(
				CollaboratorPlaceHolder.build(i)
			)
		}
		return participants
	}

	class Participant: NSObject, ObservableObject {

		@Published
		// var ckParticipant: CKShare.Participant
		var ckParticipant: Ladder_ShareParticipant

		init(_ participant: Ladder_ShareParticipant){
			ckParticipant = participant
		}
	}
}


public final class AdAstraCollaborationDebug: NSObject, AdAstraDebugProtocol {
	public static var feature = AdAstraCollaborationDebug()

  public var showFakeCollaboratorsList: Bool = false

}


#endif

