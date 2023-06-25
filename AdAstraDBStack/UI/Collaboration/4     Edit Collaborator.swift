//
//  File3.swift
//  File3
//
//  Created by cms on 10/19/21.
//

import Foundation
import SwiftUI
import SFSafeSymbols
// #if DebugWithoutCloudKit
// #else
//#if !DebugWithoutCloudKit
import CloudKit
//#endif

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

#if true //os(iOS)

@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspector_EditView: View {
	@EnvironmentObject
	var collabNav: CollaborationNavigationViewModel

	// @StateObject
	// var participantWrapper: AACollaborationViewModel.Participant

	var participant: Ladder_ShareParticipant? {
		get { collabNav.participantSelected }
		// set { participantWrapper.ckParticipant = newValue }
	}
	var permission: CKShare.ParticipantPermission? {
		get { collabNav.participantSelected?.permission }
		// set { participantWrapper.ckParticipant.permission = newValue }
	}

	var body: some View {

		List {
			Label(participant?.displayName ?? "", systemImage: SFSymbol.person.rawValue) // 􀉩
			// Label(participant.displayName, systemImage: SFSymbol.at.rawValue) // 􀅷

			if false {
				Section(header: Text("Permission").font(.caption)) {
					Group{
						Button(action: {
							collabNav.participantSelected?.permission = .readWrite
						} , label: {
							HStack {
								Text("Can make changes")
								Spacer()
								if permission == .readWrite {
									Image(systemSymbol: SFSymbol.checkmark) // 􀆅
										.foregroundColor(.accentColor)
								}
							}
						})

						Button(action: {
							collabNav.participantSelected?.permission = .readOnly
						} , label: {
							HStack {
								Text("Can view only")
								Spacer()
								if participant?.permission == .readOnly {
									Image(systemSymbol: SFSymbol.checkmark) // 􀆅
										.foregroundColor(.accentColor)
								}
							}
						})
					}
					.foregroundColor(.label)
				}
			}

			Section {
				Button(action: {
					print("pressed stop sharing")
					// TODO: add alert and add removal code
				}, label: {
					HStack {
						Spacer()
						Text("Remove Access")
							.foregroundColor(.red)
						Spacer()
					}

				})
			}

		}
#if os(iOS)
		.listStyle(InsetGroupedListStyle())
#endif

	}
}
// #endif

#endif
