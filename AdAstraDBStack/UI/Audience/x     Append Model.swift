// //
// //  File.swift
// //
// //
// //  Created by cms on 1/9/22.
// //
// 
// import Foundation
// import CoreData
// import AdAstraExtensions
//
// /*
//  Core Data Model thinking
//
//  - ProjectDBStack doesn't handle migrations, that's handled by app's subclass of ProjectDBStack. They handle any migration, get to
//
//  */
//
// extension AudienceUsher {
//    static var AudienceUsherModelName: String { "AudienceUsher_v1" }
//    static var VersionFilenameKey: String = "AudienceUsherVersionFilename"
//
//    /// Search passed metadata for a versionFilename and returns it if found, or returns nil
//   public static func FindAudienceUsherVersionFile(in modelMetadata: [String: Any]) -> String? {
//
//       // extract VersionFilenameKey's value from metadata
//       return Array(modelMetadata).last(where: { $0.key == AudienceUsher.VersionFilenameKey } )?.value as? String
//    }
//
//
//  public static func AppendAudienceUsherModel(
//       into primaryModel: NSManagedObjectModel,
//       // ProjectListingEntityName: String){
//       ParentProjectEntityName: String,
//       using givenAudienceUsherVersionFile: String? = nil) -> NSManagedObjectModel {
//
//          let modelVersionFilename: String = givenAudienceUsherVersionFile ?? AudienceUsherModelName
//
//          guard let modelURL = Bundle.module.url(
//             forResource: modelVersionFilename,
//             withExtension: "mom") else {
//             fatalError("Unable to find AudienceUsherModel CoreData modelURL")
//          }
//
//
//          guard let audienceUsherManagedObjectModel = NSManagedObjectModel(contentsOf: modelURL, addVerionID: true) else {
//             fatalError("Unable to Load AudienceUsherModel CoreData managedObjectModel")
//          }
//
//          guard let mergedManagedObjectModel =  NSManagedObjectModel.init(byMerging: [primaryModel, audienceUsherManagedObjectModel]) else {
//             fatalError("Unable to Load Merged Project + AudienceUsherModel CoreData managedObjectModel")
//          }
//
// 				guard let AudienceMemberEntity: CoreDataNSEntityDescription = mergedManagedObjectModel.entitiesByName["AudienceMember"] else { CrashAfterUserAlert🛑("") }
//          guard let GuestbookEntryEntity: CoreDataNSEntityDescription = mergedManagedObjectModel.entitiesByName["AudienceGuestbookEntry"] else { CrashAfterUserAlert("") }
//          guard let ProjectListingEntity: CoreDataNSEntityDescription = mergedManagedObjectModel.entitiesByName[ParentProjectEntityName] else { CrashAfterUserAlert("") }
//
//          //* AudienceGuestbookEntry
//          // Setup relationships of AudienceMember to app's model
//          let projectToAudienceMember = NSRelationshipDescription()
//          let audienceMemberToProject = NSRelationshipDescription()
//          projectToAudienceMember.name = "audienceMembers"
//          projectToAudienceMember.destinationEntity = AudienceMemberEntity
//
//          projectToAudienceMember.minCount = 0
//          projectToAudienceMember.maxCount = 0 // 0 for one-to-many
//          projectToAudienceMember.deleteRule = .cascadeDeleteRule
//          projectToAudienceMember.inverseRelationship = audienceMemberToProject
//          ProjectListingEntity.properties.append(projectToAudienceMember)
//
//          audienceMemberToProject.name = "parentProject"
//          audienceMemberToProject.destinationEntity = ProjectListingEntity
//          audienceMemberToProject.minCount = 1
//          audienceMemberToProject.maxCount = 1
//          audienceMemberToProject.deleteRule = .nullifyDeleteRule
//          audienceMemberToProject.inverseRelationship = projectToAudienceMember
//          AudienceMemberEntity.properties.append(audienceMemberToProject)
//
//          //* AudienceGuestbookEntry
//          // Setup relationships of AudienceGuestbookEntry to app's model
//          let projectToGuestbookEntry = NSRelationshipDescription()
//          let guestbookToProject = NSRelationshipDescription()
//          projectToGuestbookEntry.name = "guestbookEntries"
//          projectToGuestbookEntry.destinationEntity = GuestbookEntryEntity
//          projectToGuestbookEntry.minCount = 0
//          projectToGuestbookEntry.maxCount = 0 // 0 for one-to-many
//          projectToGuestbookEntry.deleteRule = .cascadeDeleteRule
//          projectToGuestbookEntry.inverseRelationship = guestbookToProject
//          ProjectListingEntity.properties.append(projectToGuestbookEntry)
//
//
//          guestbookToProject.name = "parentProject"
//          guestbookToProject.destinationEntity = ProjectListingEntity
//          guestbookToProject.minCount = 1
//          guestbookToProject.maxCount = 1
//          guestbookToProject.deleteRule = .nullifyDeleteRule
//          guestbookToProject.inverseRelationship = projectToGuestbookEntry
//          GuestbookEntryEntity.properties.append(guestbookToProject)
//
//
//          return mergedManagedObjectModel
//
//             // adapted from: https://stackoverflow.com/questions/13743242/adding-relationships-in-nsmanagedobjectmodel-to-programmatically-created-nsentit
//       }
// }
