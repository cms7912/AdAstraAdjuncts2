//
//  DragAndDropCardView     .swift
//  Caleo
//
//  Created by cms on 7/4/21.
//  Copyright © 2022 CMS. All rights reserved.
//

import Foundation

import SwiftUI
// import CoreData
import UniformTypeIdentifiers
import os.log
import AdAstraExtensions

// import AdAstraBridgingByMask


// struct DraggableCardView<Content: View>: View {
struct DragonCardView<Card: DragonCard>: ViewModifier {
  // let draggingCardOverlayColor: Color = Color.Neumorphic.main
  
  @EnvironmentObject var dragonVM: DragonViewModel<Card>
  // @EnvironmentObject var PEM: ProjectEnvironmentModels
  
  
	@State var cardData: DragonViewModel<Card>.CardData
  
  var selfCard: Card { cardData.selfCard }
  @State var mySize: CGSize?
  
  @State private var marchingAntsPhase: CGFloat = 0
  
  class ReadSizePK: BaseReadSizePreferenceKey {}
  func body(content: Content) -> some View {
    // guard !(HighlightDebug.feature.disableCardDragAndDrop) else { return content }
    
    content
    // .border(Color.green, width: 1)
      .opacity(dragonVM.sourceCardData?.selfCard == selfCard ? 0 : 1 ) // hide the card contents during drag
      .overlay( // but put background-colored overlay so that .onDrop has a target to hit (0% opacity is not a target)
        ZStack {
          if cardData.dancingAntsOnDrag &&
              dragonVM.sourceCardData?.selfCard == selfCard {
            cardData.backgroundColor
            RoundedRectangle(cornerRadius: 5, style: .continuous)
              .strokeBorder(Color.secondaryLabel,
                            style: StrokeStyle(lineWidth: 2, dash: [10],
                                               dashPhase: marchingAntsPhase))
            // .background(draggingCardOverlayColor)
              .onAppear {
                withAnimation(.linear.repeatForever(autoreverses: false)) {
                  marchingAntsPhase -= 20
                }
              }
          }
        }
      )
      .readSize(Self.ReadSizePK) {size in
        if dragonVM.inProgressOverCardID.isNotNil && dragonVM.useDropLocationForLeftOrRightInsertion {
        self.mySize = size
        }
      }
    // #if DEBUG_X
    //      .border(
    //        (HighlightDebug.feature.debugCardDragAndDrop)
    //        ? (
    //          dragging.overCard == selfCard
    //          ? Color.green
    //          : dragging.sourceCard == selfCard
    //          ? Color.blue
    //          : Color.gray
    //          // : Color.green
    //        ) :
    //          Color.clear
    //        , width: 2)
    // #endif


		// onDrop is possible to selfCard:
			.onDrop(of: cardData.droppableContentUTTypes,
							delegate:
								CardDropDelegate<Card>(
									dragonVM: dragonVM,
									destinationCardData: cardData,
									destinationCardSize: mySize
								))

		
    // onDrag this selfCard
      .onDrag {
        Logger.llog("🐲 .onDrag")

				dragonVM.sourceCardData = cardData
				dragonVM.sourceCardSourceParent = selfCard.objectParent

				// tell host app the drag starting
				dragonVM.sourceCardData?.sourceCardDragStarted()

				return NSItemProvider(item: selfCard.objectIDEncoded,
															typeIdentifier: cardData.selfContentUTTType?.identifier)
      }



  }
}





