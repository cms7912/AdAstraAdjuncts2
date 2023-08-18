//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
// import SwiftUI
import CoreData
// import SFSafeSymbols
import CloudKit
import AdAstraExtensions
import AALogger
//import AdAstraBridgingByShim

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif


#if os(iOS)

// @objc
extension UIApplicationDelegate {
#if !DebugWithoutCloudKit
	@available(iOS 14.4, macCatalyst 14.4, *)
	public func application(_ application: UIApplicationDelegate, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {

		if #available(iOS 15.0, macCatalyst 15.0, *) {
			guard let sharedStack = ProjectsDBStack.shared else {
				LLog("Unexpectedly received application(userDidAcceptCloudKitShareWith:) notification while not having a sharedStack")
				return
			}
			guard let sharedStore = ProjectsDBStack.shared?.sharedPersistentStore else {
				print("Unexpectedly received application(userDidAcceptCloudKitShareWith:) notification while not having a sharedStore")
				return
			}
			let container = sharedStack.container
			container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore, completion: nil)
		}
	}
#endif

}
#endif
