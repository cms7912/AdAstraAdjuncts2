//
//  Draggable Card VM and View Modifier.swift
//  Caleo
//
//  Created by cms on 7/4/21.
//  Copyright © 2022 CMS. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import UniformTypeIdentifiers

///
public class DragonViewModel<Card: DragonCard>: ObservableObject {
	public init(sourceCardData: DragonViewModel<Card>.CardData? = nil,
							sourceCardSourceParent: Card.Parent? = nil,
							inProgressOverCardID: Card.ID? = nil,
							dragonDelegate: DragonDelegate?) {
		self.sourceCardData = sourceCardData
		self.sourceCardSourceParent = sourceCardSourceParent
		self.inProgressOverCardID = inProgressOverCardID
		self.dragonDelegate = dragonDelegate
	}


	let useDropLocationForLeftOrRightInsertion: Bool = true
	@Published var sourceCardData: CardData?
	var sourceCardSourceParent: Card.Parent?
	// @Published var overCard: Card?
	// @Published var inProgress: Bool = false
	@Published var inProgressOverCardID: Card.ID? // = false

	weak var dragonDelegate: DragonDelegate?
}

public protocol DragonDelegate: AnyObject {
  
}

public extension DragonViewModel {
	struct CardData {
		public init(axis: Binding<Axis.Set>,
								selfCard: Card,
								selfContentUTTType: UTType? = nil,
								droppableContentUTTypes: [UTType] = .empty,
								backgroundColor: Color,
								dancingAntsOnDrag: Bool = true,
								sourceCardDragStarted: @escaping () -> Void = {},
								sourceCardDropUpdated: @escaping ((Card) -> Void) = {_ in },
								sourceCardPerformDrop: @escaping ((Card) -> Void) = {_ in }) {
			self._axis = axis
			self.selfCard = selfCard
			self.selfContentUTTType = selfContentUTTType
			self.droppableContentUTTypes = droppableContentUTTypes
			self.backgroundColor = backgroundColor
			self.dancingAntsOnDrag = dancingAntsOnDrag
			self.sourceCardDragStarted = sourceCardDragStarted
			self.sourceCardDropUpdated = sourceCardDropUpdated
			self.sourceCardPerformDrop = sourceCardPerformDrop
		}


		@Binding var axis: Axis.Set
		var selfCard: Card
		var selfContentUTTType: UTType?
		var droppableContentUTTypes: [UTType] = .empty
		var backgroundColor: Color
		var dancingAntsOnDrag: Bool =  true

		var sourceCardDragStarted: () -> Void = {}
		/*
		 for Highlight to use as 'sourceCardDragStarted'

		 try? sourceCard.managedObjectContext?.save()

		 */

		var sourceCardDropUpdated: ((_ destinationCard: Card) -> Void) = {_ in }
		/*
		 for Highlight to use as 'sourceCardDropUpdated'
		 if sourceCard.hasCode {
		 // dropping a code
		 sourceCard.code?.parentCode = newCodeOfDestination
		 } else if sourceCard.hasSnippet {
		 // dropping a snippet
		 sourceCard.snippet?.code = newCodeOfDestination
		 }
		 */
		var sourceCardPerformDrop: ((_ destinationCard: Card) -> Void) = {_ in }
		/*
		 for Highlight to use as 'sourceCardPerformDrop'

		 try? selfCard.managedObjectContext?.save()

		 // Update snapshot if card has a snippet
		 selfCard.snippet?.updateSnapshot(qos: .userInteractive)


		 if let projectObjectID = dragonVM.parentEnvironment?.projectObjectID {
		 // normalize the sortOrder of Cards
		 Card.NormalizeSortOrder(
		 parentProjectID: projectObjectID,
		 for: newCodeOfDestination)
		 if newCodeOfDestination != dragonVM.sourceCardOriginalParentCode {
		 // changed codes from source card's original code. So also normalize the original parentCode
		 Card.NormalizeSortOrder(
		 parentProjectID: projectObjectID,
		 for: dragonVM.sourceCardOriginalParentCode)
		 }
		 }

		 */
	}
}



// extension View where Card == DragonCard {
extension View {
  // func dragonDrop<Card: DragonCard>(axis: Binding<Axis.Set>, _ card: Card) -> some View {
	public func dragonDrop<Card: DragonCard>(_ cardData: DragonViewModel<Card>.CardData) -> some View {
    // let cardDataView = cardDataViewClosure()
    return self.modifier(
			DragonCardView(
				cardData: cardData))
  }
}




