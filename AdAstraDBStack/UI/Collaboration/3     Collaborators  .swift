//
//  File.swift
//  File
//
//  Created by cms on 10/19/21.
//

import Foundation
import SwiftUI
import SFSafeSymbols
#if DebugWithoutCloudKit
// import AdAstraAdjuncts
#else
// import AdAstraAdjuncts
#endif

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
//import AdAstraBridgingByShim <-

#if true // os(iOS)

@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspector_MainView_CollaboratorsList: View {
  @EnvironmentObject
  var collabModel: AACollaborationViewModel

  @State var participantID: String?

  var zeroParticipants: Bool { collabModel.participants.isEmpty }
  var body: some View {
    // remember this is a section within the CollaborationInspectorView's overall list

    Section(header: Text(zeroParticipants ? "" : "Current Collaborators")) {
      // ForEach(1..<5) { i in
      ForEach(collabModel.participants, id: \.uniqueIDOrUUID) { participant in
        // 				NavigationLink(destination:
        // 												CollaboratorEditView(participantWrapper:
        // 																							AACollaborationViewModel.Participant(participant)) ,
        // 											 tag: participant.uniqueIDOrUUID,
        // 											 selection: $participantID
        // 				) {
        // 					CollaborationInspector_CollaboratorsList_Row(participant: participant)
        // 				}
        // #if os(iOS)
        // 				.isDetailLink(false)
        // #endif

        CollaborationInspector_MainView_CollaboratorsList_Row(participant: participant)
      }
      .onDelete(perform: collabModel.userIsOwner ? removeParticipant : nil)

      if collabModel.userIsOwner {
        // only show adding collaborators button if user is owner
        CollaborationInspectorView_AddCollaboratorsButton()
      }
    }
    .onAppear{
      collabModel.refreshParticipants()
    }
  }


  func removeParticipant(at offsets: IndexSet) {
    offsets.forEach{
      let participant = collabModel.participants[$0]
    }
  }
}


@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspector_MainView_CollaboratorsList_Row: View {
  @EnvironmentObject
  var collabModel: AACollaborationViewModel
  @EnvironmentObject
  var collabNav: CollaborationNavigationViewModel

  @State var participant: Ladder_ShareParticipant

  var body: some View {
    Button(action: {
      collabNav.participantSelected = participant
    }) {
      Label {
        VStack(alignment: .leading) {
          Text(participant.displayName ?? "")

          Text(participant.dashboardString)
            .font(.caption)
            .foregroundColor(.secondaryLabel)
        }
      } icon: {
        Circle()
          .fill(
            collabModel.colorForCollaboratorID(participant.uniqueIDOrUUID)
              ?? Color.systemBlue
          )
          .frame(width: 33, height: 33, alignment: .center)
          .overlay(
            Text(participant.initials)
              .foregroundColor(.label)
              .bold()
              // .font(.center)
              .multilineTextAlignment(.center)
          )

        // .alpha(participant.acceptanceStatus == .pending ? 0.5 : 1.0)
      }
      // .alpha(participant.acceptanceStatus == .removed ? 0.25 : 1.0)
    }
  }
}



@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaborationInspectorView_AddCollaboratorsButton: View {
  @EnvironmentObject
  var collabModel: AACollaborationViewModel

  @State var collaboratorID: UUID?

  var zeroParticipants: Bool { collabModel.participants.isEmpty }
  var body: some View {
    // remember this is a section within the CollaborationInspectorView's overall list

    Section {
      // - Add Collaborator Button -
      // 􀉯  􀉯  􀉯
      HStack{
        Spacer()
        Button(action: {
          print("pressed Add collaborator")
          collabModel.addCollaborator()
        }, label: {
          Label(
            "Add Collaborators",
            systemImage: SFSymbol.personCropCircleBadgePlus.rawValue // 􀉯
          )
          .foregroundColor(.label)
          // .availableiOS15.symbolRenderingMode(".hierarchical")
        })
        .buttonStyle(.borderedProminent)
        Spacer()
      }
    }
  }
}



#endif
