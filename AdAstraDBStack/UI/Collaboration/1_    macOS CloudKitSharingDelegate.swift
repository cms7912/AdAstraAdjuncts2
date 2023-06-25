//
//  File.swift
//  
//
//  Created by cms on 12/8/21.
//

import Foundation
import CloudKit
import CoreData

#if os(macOS)
import AppKit
// import CryptorRSA
// import Cryptor
import CryptoKit
// import CryptoTokenKit

@available(macCatalyst 15, iOS 15, macOS 12, *)
extension AACollaborationViewModel {

	class CloudKitSharingControllerDelegate: NSObject, NSCloudSharingServiceDelegate {
		enum SharingPermission {
			case readWrite
			case readOnly
		}
		// https://developer.apple.com/documentation/appkit/nssharingservice
		// https://developer.apple.com/documentation/appkit/nscloudsharingservicedelegate

		weak var parentModel: AACollaborationViewModel?
		// weak var cloudSharingViewController: UICloudSharingController?

		var projectListing: AAProjectListingProtocol
		let container: CoreData.NSPersistentCloudKitContainer

		init?(_ parentModel: AACollaborationViewModel) {
			self.parentModel = parentModel
			self.projectListing = parentModel.projectListing
			guard let sharedStack = ProjectsDBStack.shared else {
				return nil
			}
			self.container = sharedStack.container
		}

		func addCollaborator( with permissions: CloudKitSharingControllerDelegate.SharingPermission? = nil ){

			let nsPermissions: NSSharingService.CloudKitOptions?
			switch permissions {
				case .readWrite:
					nsPermissions = NSSharingService.CloudKitOptions.allowReadWrite
				case .readOnly:
					nsPermissions = NSSharingService.CloudKitOptions.allowReadOnly
				default:
					nsPermissions = nil
			}

			container.share([projectListing], to: nil) { [self] objectIDs, share, container, error in
				if let actualShare = share {
					projectListing.managedObjectContext?.performAndWait {
						actualShare[CKShare.SystemFieldKey.title] = projectListing.presentableName

						//TODO: attach 'actualShare' to a NSItemProvider and submit to NSSharingServices

					}
				}
				if let error = error {
					llog("Error \(error.localizedDescription)", .error)
				}
			}

		}
		func deleteShare() {
			// let container = LadderDBStack.shared.container
			guard let ckShareRecordID = parentModel?.ckShare?.recordID else { return }

			let modifyOp = CKModifyRecordsOperation(recordsToSave: nil
													, recordIDsToDelete: [ckShareRecordID] )
			CKContainer.default().privateCloudDatabase.add(modifyOp)

		}

		/*
		 ?? needed?
		func shares(matching objectIDs: [NSManagedObjectID]) throws -> [NSManagedObjectID: Ladder_Share] {
			return try container.fetchShares(matching: objectIDs)
		}
*/

		var canEdit: Bool { return canEdit(object: projectListing) }
		func canEdit(object: CoreData.NSManagedObject) -> Bool {
			return container.canUpdateRecord(forManagedObjectWith: object.objectID)
		}

		var canDelete: Bool { return canDelete(object: projectListing) }
		func canDelete(object: CoreData.NSManagedObject) -> Bool { return container.canDeleteRecord(forManagedObjectWith: object.objectID)
		}


		// Default delegate calls:
		func sharingService(_ service: NSSharingService, didCompleteForItems: [Any], error: Error?){ }

		func sharingService(_ service: NSSharingService, didSave: CKShare){ }

		func sharingService(_ service: NSSharingService, didStopSharing: CKShare){ }

		func options(for service: NSSharingService, share: NSItemProvider) -> NSSharingService.CloudKitOptions {
			return [.allowReadWrite, .allowPublic, .allowPrivate]
			// return [.standard]
		}



	}



}


#endif
