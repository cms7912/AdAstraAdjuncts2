
//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
// import SwiftUI
// import UIKit
import CoreData
// import SFSafeSymbols

import CloudKit




public protocol AAProjectListingProtocol: NSManagedObject {
	var presentableName: String { get }
	var createdTimestamp: Date? { get }
  var context: NSManagedObjectContext { get }
}


@available(macCatalyst 15, iOS 15, macOS 12, *)
extension AAProjectListingProtocol {
	public var isShared: Bool {
		var isShared = false

		if let persistentStore = self.objectID.persistentStore {
			// if persistentStore == ProjectsDBStackShared?.sharedPersistentStore {
			if persistentStore == ProjectsDBStack.shared?.sharedPersistentStore {
				isShared = true
			} else {
				// let container = ProjectsDBStackShared.container
					let shares = try? ProjectsDBStack.shared?.container.fetchShares(matching: [self.objectID])
					if nil != shares?.first {
						isShared = true
					}
			}
		}
		return isShared
	}

	public var userIsOwner: Bool {
		let ckShares: [NSManagedObjectID: CKShare] = ( try? ProjectsDBStack.shared?.container.fetchShares(matching: [self.objectID]) ) ?? [NSManagedObjectID: CKShare]()

		if let projectShare = ckShares[self.objectID] {
			return projectShare.currentUserParticipant == projectShare.owner
		}
		return true // private project
	}


}

@objc(AAProjectListing)
open class AAProjectListing: AdAstraNSManagedObject, AAProjectListingProtocol {
  // public var context: NSManagedObjectContext
  
	open var presentableName: String { return "" }
	open var createdTimestamp: Date? { return nil }
}

