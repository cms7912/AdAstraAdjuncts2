//
//  Share Details View.swift
//  Pilot - Highlight SwiftUI
//
//  Created by cms on 12/29/20.
//

import Foundation
import SwiftUI
import SFSafeSymbols
// import UIKit
#if DEBUG

// @available(macCatalyst 15, iOS 15, *)
// struct CollaborationInspectorView_Previews: PreviewProvider {
//
// 	static var previews: some View {
// 		CollaborationInspectorView_SubPreviews()
// 	}
// }
//
//
// @available(macCatalyst 15, iOS 15, *)
// struct CollaborationInspectorView_SubPreviews: View {
// 	@StateObject
// 	var collaborationViewModel: CollaborationViewModel = CollaborationViewModel(for: DBStack.shared.projectLadderPlaceholder!)
//
// 	var body: some View {
// 		// CollaborationInspectorView(){}
// 		Group {
// 			CollaborationInspectorView(collabModel: collaborationViewModel)
// 			// ShareCollaboratorView()
// 			// .previewDevice("iPhone 12")
// 			// .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//
// 			// CollaborationInspectorView(){}
// 			CollaboratorEditView(participantWrapper:
// 									CollaborationViewModel.Participant(
// 									CollaboratorPlaceHolder.build(1) )
// 			)
//
// 		}
// 		.preferredColorScheme(.dark)
// 		.previewDevice("iPhone 12 mini")
// 		.environmentObject(collaborationViewModel)
// 	}
// }
// var TESTING: Bool = true
var TESTING: Bool = false
#else
var TESTING: Bool = false
#endif

#if true //os(iOS)

class CollaborationNavigationViewModel: ObservableObject {
	enum page {
		case overview
		case participant
	}

	// @Published var participantSelected: String?
	@Published var participantSelected: Ladder_ShareParticipant?

	lazy var participantIsSelected = Binding<Bool>(
		get: {
			self.participantSelected.isNotNil
		},
		set: {
			if $0 == false {
				self.participantSelected = nil
			} else {
				// not sure what to do here if ...
				// participantSelected
			}
		}
	)

}


@available(macCatalyst 15, iOS 15, macOS 12.0, *)
public struct CollaborationInspectorView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  @StateObject var collabNav = CollaborationNavigationViewModel()
  public init(){ }
  
  var iCloudIsAvailable: Bool {
    FileManager.default.ubiquityIdentityToken != nil
  }
  
  var embedInExistingNavigationView: Bool {
    horizontalSizeClass == .compact
  }
  
  public var body: some View {
    // Group{
    if iCloudIsAvailable {
      // Group{
      ZStack {
        // in compact mode, the participant-detail taps activates this:
        if embedInExistingNavigationView {
          NavigationLink(
            destination:
              CollaborationInspector_EditView()
            , isActive: collabNav.participantIsSelected
            , label: {
              EmptyView()
            }
          )
        } else {
          // in .regular sized view, handle transitions:
          
          if collabNav.participantSelected == nil {
            // show overview page
            CollaborationInspector_MainView()
            // .transition(AnyTransition.move(edge: .leading)).animation(.default)
            
          } else {
            CollaborationInspector_EditView()
            // .transition(AnyTransition.move(edge: .trailing)).animation(.default)
          }
          // these '.transition' animations are causing all subviews to also animate on movement (e.g. window resizing).
          
          // https://stackoverflow.com/questions/61424225/macos-swiftui-navigation-for-a-single-view
        }
        
      }
      .environmentObject(collabNav)
      
    } else {
			VStack{
				Spacer()
				Image(systemSymbol: .icloud)
					.imageScale(.large)

				Text("Sign in to iCloud to sync and collaborate.")
					.multilineTextAlignment(.center)
					.padding(.horizontal)
					.padding(.horizontal)
				Spacer()
				Button(
					action: {openiCloudSettings() }
					) { Label("Sign in to iCloud", systemSymbol: .icloud) }
				//.labelStyle(.titleOnly))
					.buttonStyle(.borderedProminent)
					.controlSize(.large)
				Spacer()
				Spacer()
			}
			.foregroundColor(.secondaryLabel)

      // }
    }
  }

	func openiCloudSettings(){
		#if os(macOS)
		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"))
		// https://stackoverflow.com/questions/52751941/how-to-launch-system-preferences-to-a-specific-preference-pane-using-bundle-iden
		#elseif os(iOS)
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
       UIApplication.shared.canOpenURL(settingsUrl) {
			UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
				print("Settings opened: \(success)") // Prints true
			})}
			// https://stackoverflow.com/questions/28152526/how-do-i-open-phone-settings-when-a-button-is-clicked
		#endif
	}
}
@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspector_MainView: View {
	// @EnvironmentObject
	// var projectListing: AAProjectListingProtocol

	@EnvironmentObject
	var collabModel: AACollaborationViewModel

	// @AppStorage("Collaboration_EditingPrivilegesForNewCollaborator") var editingPrivilegesForNewCollaborator: Bool = false

	// @State var activeSheetDismiss: () -> Void



	var body: some View {
		// ScrollView{
			List {

				CollaborationInspector_MainView_CollaboratorsList()

                // CollaborationInspectorView_EditingSettings()

				if collabModel.userIsOwner {
					Collaboration_ShareLinksButton()
						.frame(alignment: .center)
				}

				// Stop Sharing:
				if (collabModel.isShared && collabModel.userIsOwner) || TESTING {
					Collaboration_StopSharingButton()
						.frame(alignment: .center)
				}
			}
#if os(iOS)
			.listStyle(InsetGroupedListStyle())
#endif
			.padding(.bottom, 20) // simply let the view scroll up further
			// .frame(height: 2000)
			// .navigationBarHidden(true)

		// }
		// .clipped()
		.onAppear{
			collabModel.inspectorDidAppear()
		}
	}
}



#endif
