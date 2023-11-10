//
//  File.swift
//  
//
//  Created by cms on 12/8/21.
//

import Foundation
import CloudKit
import CoreData

import AdAstraExtensions

#if os(iOS)
import UIKit
//import Caleo

@available(macCatalyst 15, iOS 15, macOS 12, *)
extension AACollaborationViewModel {

	class CloudKitSharingControllerDelegate: NSObject, UICloudSharingControllerDelegate {
		enum SharingPermission {
			case readWrite
			case readOnly
		}

		weak var parentModel: AACollaborationViewModel?
		weak var cloudSharingViewController: UICloudSharingController?

		var projectListing: AAProjectListingProtocol
		let container: NSPersistentCloudKitContainer

		init?(_ parentModel: AACollaborationViewModel) {
			self.parentModel = parentModel
			self.projectListing = parentModel.projectListing
			guard let sharedStack = ProjectsDBStack.shared else {
				return nil
			}
			self.container = sharedStack.container
		}

		func addCollaborator( with permissions: CloudKitSharingControllerDelegate.SharingPermission? = nil ){
			guard let parentModel = self.parentModel else { return }
			let uiPermissions: UICloudSharingController.PermissionOptions?

			switch permissions {
				case .readWrite:
					uiPermissions = UICloudSharingController.PermissionOptions.allowReadWrite
				case .readOnly:
					uiPermissions = UICloudSharingController.PermissionOptions.allowReadOnly
				default:
					uiPermissions = nil
			}

			var cloudSharingViewController_: UICloudSharingController?


			// create share ViewController
			if let ckShare: CKShare = parentModel.fetchExistingCKShare() {
				// ckShare exists
				llog("cloudSharingViewController will used existing ckShare")

				cloudSharingViewController_ = UICloudSharingController(share: ckShare, container: parentModel.ckContainer)

			} else {
				// need to create a new ckShare
				llog("cloudSharingViewController will create a new ckShare")
				cloudSharingViewController_ = UICloudSharingController(preparationHandler: { [self] (controller, preparationCompletedHandler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
					// 'preparationHandler' is called *first* -- it allows developer to set up the ckShare and to save the ckRecord and the ckShare. Then once that's done developer calls the completion handler to let UICloudSharingController know the share is ready
					llog("preparationHandler started")

					llog( """
projectListing is in \({  () -> String in
   var location: String = ""
   if projectListing.objectID.persistentStore == ProjectsDBStack.shared?.privatePersistentStore {
	location.append ("privatePersistentStore")
   }
   if projectListing.objectID.persistentStore == ProjectsDBStack.shared?.sharedPersistentStore {
	location.append ("sharedPersistentStore")
   }
   return location
  }() )
""")

					// Create share
					container.share([projectListing], to: nil) { [self] objectIDs, share, ckContainer, error in
						llog("container.share completionHandler started")

						if let actualShare = share {
							llog("container.share created ckShare")

							// save cache of the share
							self.parentModel?.ckShare = actualShare

							// Update ckShare's presented title
							projectListing.managedObjectContext?.performAndWait {
								actualShare[CKShare.SystemFieldKey.title] = projectListing.presentableName
							}

							if let sharedStore = ProjectsDBStack.shared?.sharedPersistentStore {

								ProjectsDBStack.shared?.container.persistUpdatedShare(
									actualShare, in: sharedStore) {share, error in
										llog("completed persistUpdatedShare")
										llog("ckShare exists: \(share != nil )")
										llog("error exists: \(error != nil )")
										if let error = error {
											llog ("error: \(error.localizedDescription)")
										}
									}
							} else {
								llog("⚠️ no shared persistent store")
							}

							llog( """
projectListing is in \({  () -> String in
   var location: String = ""
   if projectListing.objectID.persistentStore == ProjectsDBStack.shared?.privatePersistentStore {
 location.append ("privatePersistentStore")
   }
   if projectListing.objectID.persistentStore == ProjectsDBStack.shared?.sharedPersistentStore {
 location.append ("sharedPersistentStore")
   }
   return location
  }() )
""")


							//temp:
							if let ckRecord = ProjectsDBStack.shared?.container.record(for: self.projectListing.objectID) {

								llog(actualShare.recordID.zoneID.zoneName)
								llog(ckRecord.recordID.zoneID.zoneName)
								if actualShare.recordID.zoneID == ckRecord.recordID.zoneID {
									llog("!!! zones are the same in UICloudSharingController")
								} else {
									llog ("-_- zones are different in UICloudSharingController")
								}
							}
							// //


						} else {
							llog("⚠️ container.share failed to create ckShare")
						}

						llog("container.share completionHandler started")
						llog("will call preparationHandler's preparationCompletedHandler")
						preparationCompletedHandler(share, ckContainer, error)
						llog("did call preparationHandler's preparationCompletedHandler")
					}
					llog("preparationHandler finished")
				})

			}

			// https://stackoverflow.com/questions/40514231/how-to-create-a-share-with-cloudkits-ckshare
// https://stackoverflow.com/questions/68021957/how-is-record-zone-sharing-done/68072464#68072464

			//https://stackoverflow.com/questions/42148151/cannot-share-cloudkit-ckshare-record/60683437#60683437


			guard let cloudSharingViewController = cloudSharingViewController_ else {
				self.llog("🛑 failed to create cloudSharingViewController")
				return
			}

			cloudSharingViewController.modalPresentationStyle = .formSheet

			cloudSharingViewController.delegate = self
			// cloudSharingViewController.availablePermissions = permissions ?? [.allowReadWrite, .allowPublic, .allowPrivate, .allowReadOnly] // default to allowing all
			cloudSharingViewController.availablePermissions = // permissions ??
			[.allowReadWrite, .allowPublic, .allowPrivate] // default to allowing editing

			// if let button = self.button {
			// 	cloudSharingController.popoverPresentationController?.sourceView = button
			// }

			UIApplication.shared.windows.first?.rootViewController?.present(cloudSharingViewController, animated: true)

			// self.cloudSharingViewController = cloudSharingViewController
			// self.objectWillChange.send()
		}
		func deleteShare() {
			// let container = LadderDBStack.shared.container
			guard let ckShareRecordID = parentModel?.ckShare?.recordID else { return }

			let modifyOp = CKModifyRecordsOperation(recordsToSave: nil
													, recordIDsToDelete: [ckShareRecordID] )
			// modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
			// 										   error) in
			// 	handler(share, CKContainer.default(), error)
			// }
			CKContainer.default().privateCloudDatabase.add(modifyOp)
		}

		public func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
			llog("Failed to save share \(error)")

			// the below cases listed are recoverable errors
			switch error {
				case CKError.changeTokenExpired:
					llog("🛑 Failed to save share - changeTokenExpired")
					return
				case CKError.zoneNotFound:
					llog("Zone not found -- is this a first-time occurrence before NSPersistentCloudKitContainer will create the zone?")
				case CKError.accountTemporarilyUnavailable:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.alreadyShared:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.networkFailure: // iCloud inaccessable
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.networkUnavailable:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.notAuthenticated:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.partialFailure:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return

				case CKError.permissionFailure:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return

				case CKError.serverRecordChanged:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return
				case CKError.serverRejectedRequest:
					llog("⚠️ \(error) \(error.localizedDescription)")
					return


				default:
						// any other case is an unkown state
          // CrashDuringDebug🛑("Failed to save share \(error)")
          fatalError("Failed to save share \(error)")
			}


		}

		public func itemTitle(for csc: UICloudSharingController) -> String? {
			projectListing.presentableName
		}
		public func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
			if let image = self.parentModel?.projectListingThumbnailIcon(){
				return image.pngData()
			}
			return Bundle.main.icon?.pngData()
		}
		public func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
			// called by UICloudSharingController only when its presented and updates the ckShare
			llog("did save share")
			parentModel?.fetchExistingCKShare() // keep cached ckShare updated
			parentModel?.refreshParticipants()
		}
		public func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
			// called by UICloudSharingController only when its presented and updates the ckShare
			llog ("did stop sharing")
			parentModel?.fetchExistingCKShare() // keep cached ckShare updated
		}
		/*
		 ?? needed?
		 func shares(matching objectIDs: [NSManagedObjectID]) throws -> [NSManagedObjectID: Ladder_Share] {
		 return try container.fet3hShares(matching: objectIDs)
		 }
		 */
		var canEdit: Bool { return canEdit(object: projectListing) }
		func canEdit(object: NSManagedObject) -> Bool {
			return container.canUpdateRecord(forManagedObjectWith: object.objectID)
		}

		var canDelete: Bool { return canDelete(object: projectListing) }
		func canDelete(object: NSManagedObject) -> Bool { return container.canDeleteRecord(forManagedObjectWith: object.objectID)
		}


	}


}

#endif
