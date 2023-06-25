//
//  File2.swift
//  File2
//
//  Created by cms on 10/19/21.
//

import Foundation
import SwiftUI
import SFSafeSymbols

#if true //os(iOS)

@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspectorView_NewCollaboratorsPermissionsSection: View {
	// decided to simply use the CloudShare sheet's permissions to set these on each share

	@EnvironmentObject
	var collaborationViewModel: AACollaborationViewModel

	@Binding
	var editingPrivilegesForNewCollaborator: Bool

	var body: some View {
		// remember this is a section within the CollaborationInspectorView's overall list
		Section(header: Text("New Collaborators")
				// , footer: Text("Only people you invite will be able to access this project.")
					// .font(.caption)
		) {
			Group {
			Button(action: {
				print("pressed editing privileges ")
				editingPrivilegesForNewCollaborator = !editingPrivilegesForNewCollaborator
			} , label: {
				HStack {
					Text("Can make changes") // text from CloudSharing sheet
					Spacer()
					if editingPrivilegesForNewCollaborator {
						Image(systemSymbol: .checkmark) // 􀆅
							.foregroundColor(.accentColor)
					}
				}
			})

			Button(action: {
				print("pressed viewing privileges ")
				editingPrivilegesForNewCollaborator = !editingPrivilegesForNewCollaborator
			} , label: {
				HStack {
					Text("View only") // text from CloudSharing sheet
					Spacer()
					if !editingPrivilegesForNewCollaborator {
						Image(systemSymbol: .checkmark) // 􀆅
							.foregroundColor(.accentColor)
					}
				}
			})
			}
		.foregroundColor(.label)
		}
	}
}


@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspectorView_EditingSettings: View {
	@EnvironmentObject
	var collaborationViewModel: AACollaborationViewModel

	@State var toggle: Bool = false

	var body: some View {
		Section {

			// 􀜕  􀜕  􀜕
			Toggle(isOn: $toggle) {
				Label("Badge rows by contributor", systemImage: SFSymbol.personBadgePlus.rawValue) // 􀜕
			}

			// 􀆿  􀆿  􀆿
			Toggle(isOn: $toggle) {
				Label("Highlight recent additions", systemImage: SFSymbol.sparkles.rawValue) // 􀆿
			}

			// 􀑏  􀑏  􀑏
			Toggle(isOn: $toggle) {
				Label("Receive alerts on edits", systemImage: SFSymbol.appBadge.rawValue) // 􀑏
			}
		}
	}
}


@available(macCatalyst 15, iOS 15, macOS 12, *)
struct Collaboration_ShareLinksButton: View {
    @EnvironmentObject
    var collaborationViewModel: AACollaborationViewModel
    
	var body: some View {
		Section {
			HStack {
				Spacer()

				Button(action: {
					collaborationViewModel.addCollaborator(with: .readWrite )
				}, label: {
					Text("Share link for collaborating")
					// .foregroundColor(.appPrimary)
				})

				Spacer()
			}
			if false {
				Button(action: {
					collaborationViewModel.addCollaborator(with: .readOnly )
				}, label: {
					HStack {
						Spacer()
						Text("Share link for viewing")
						// .foregroundColor(.appPrimary)
						Spacer()
					}
				})
			}
		}

	}
}


@available(macCatalyst 15, iOS 15, macOS 12, *)
struct Collaboration_StopSharingButton: View {

	@EnvironmentObject
	var collaborationViewModel: AACollaborationViewModel

	@State private var showingAlert = false

	var body: some View {
		Section {
			Button(action: {
				collaborationViewModel.deleteShare()
			}, label: {
				HStack {
					Spacer()
					Text("Stop Sharing")
						.foregroundColor(.red)
					Spacer()
				}
			})
				.alert("Stopping sharing will remove access for everyone but yourself", isPresented: $showingAlert) {
					Button("Stop", role: .destructive) {
						collaborationViewModel.deleteShare()
					}
					Button("Cencel", role: .cancel) { }
				}
		}
	}
}

#endif
