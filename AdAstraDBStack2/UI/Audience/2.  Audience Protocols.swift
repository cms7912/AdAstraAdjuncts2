//
//  File.swift
//  
//
//  Created by cms on 1/15/22.
//

import Foundation
import CoreData

@objc
public protocol AudienceParentProjectProtocol {
   // var guestbookEntries: [AudienceGuestbookEntry] { get }
   // var audienceMembers: [AudienceMember] { get }
}


@objc
public protocol GuestbookEntryEntityProtocol: NSFetchRequestResult {
   var objectID: NSManagedObjectID { get }
   var debugDescription: String { get }
var appInstallID: UUID? { get set }
   var cloudKitUser_PersonNameComponents_Store: Data? { get set }
   var cloudKitUserID: String? { get set }
   var createdTimestamp: Date? { get set }
   var deviceIdentifier: String? { get set }
   var firstAccessTimestamp: Date? { get set }
   
   var mostRecentAccessTimestamp: Date? { get set }
   var mostRecentCaleoAppVerion: String? { get set }
   var mostRecentDBVersion: String? { get set }
   func updateRecents()
   
   var parentProject: AudienceParentProjectProtocol? { get set }
   var attendees: [AttendeeEntityProtocol] { get set }
}
extension GuestbookEntryEntityProtocol {
   static var EntityName: String { "AudienceGuestbookEntry" }
}

@objc
public protocol AttendeeEntityProtocol: NSFetchRequestResult {
   var objectID: NSManagedObjectID { get }
   var debugDescription: String { get }

   var appSceneID: UUID? { get set }
   var createdTimestamp: Date? { get set }
   var lastObservationTimestamp: Date? { get set }
   
   var parentProject: AudienceParentProjectProtocol? { get set }
   var signedGuestbookEntry: GuestbookEntryEntityProtocol? { get set }
   
   // NSManagedObject interface:
   func delete()
   
   // AdAstraNSManagedObject interface:
   
   
}
extension AttendeeEntityProtocol {
   
   static var multipleAppScenesConnected: Bool {
      // UIApplication.shared.connectedScenes.count > 1
      false
   }
   
   // static func new(into context: NSManagedObjectContext) -> AudienceMemberEntityProtocol {
   //    CanonicalEntity.init(into: context)
   // // constructed from Ash's example: https://stackoverflow.com/questions/30063233/store-type-in-variable-to-use-like-a-type-later
   // }
   //
   
}
typealias AttendeeProxy = AttendeeEntityProtocol
