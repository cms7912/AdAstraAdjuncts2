//
//  Drop Delegate.swift
//  Caleo
//
//  Created by cms on 7/4/21.
//  Copyright © 2022 CMS. All rights reserved.
//

import Foundation
import os.log
import UniformTypeIdentifiers
import SwiftUI
import CoreData
import AALogger

public protocol DragonCard: Equatable, DragonCardParent {
  associatedtype ID: Equatable
  // associatedtype SO: Comparable
	associatedtype SO: BinaryFloatingPoint
	associatedtype Parent: DragonCardParent

  var objectID: ID { get }
	var objectIDEncoded: NSSecureCoding { get }
	var objectParent: Parent? { get }

  var sortOrder: SO { get set }
  // static var defaultSortOrder: SO { get }


  // var code: TempDragonCard? { get set }
  // var snippet: TempDragonCard? { get set }
}

public protocol DragonCardParent: Equatable {
	associatedtype ID: Equatable
	var objectID: ID { get }
  // static func NormalizeChildrenSortOrder<DragonCard>(for: DragonCard)
  static func NormalizeChildrenSortOrder(for _: Self?)

}

// class TempDragonCard: DragonCard {
//   static func == (lhs: TempDragonCard, rhs: TempDragonCard) -> Bool {
//     lhs.objectID == rhs.objectID
//   }
//
//   typealias ID = UUID
//   typealias SO = Int
//   var objectID: UUID
//   var sortOrder: Int
//   var code: TempDragonCard?
//   var snippet: TempDragonCard?
// }


struct CardDropDelegate<Card: DragonCard>: DropDelegate {
  internal init(dragonVM: DragonViewModel<Card>,
                destinationCardData:  DragonViewModel<Card>.CardData,
                destinationCardSize: CGSize? = nil) {
    self.dragonVM = dragonVM
    self.destinationCardData = destinationCardData
    self.destinationCardSize = destinationCardSize
    Logger.llog("🐲 CardDropDelegate init")
  }
  func llog(_ string: String? = nil, function: String = #function) {
    Logger.llog("🐲 \(string ?? "")", function: function)
  }
  
  let dragonVM: DragonViewModel<Card>
	var sourceCardData: DragonViewModel<Card>.CardData? { dragonVM.sourceCardData }
  var sourceCard: Card? { dragonVM.sourceCardData?.selfCard }
var destinationCardData: DragonViewModel<Card>.CardData // this is the card that sent this delegate
	var destinationCard: Card { destinationCardData.selfCard }
  var destinationCardSize: CGSize? // this card sent this delegate's functions
  
  func dropEntered(info: DropInfo) {
    llog("⬇️")
    dragInProgress(info: info)
		guard self.sourceCard.isNotNil else {
      return
    }
    // dragging.inProgress = true
  }
  
  func dropExited(info: DropInfo) {
    llog("⬆️")
    if dragonVM.inProgressOverCardID == self.sourceCard?.objectID {
    dragonVM.inProgressOverCardID = nil
    }
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    llog()
    // dragging.inProgress = true
		guard let sourceCard = self.sourceCard else {
      llog("⚠️ unexpectedly did not unwrap self.sourceCard")
      return DropProposal(operation: .cancel)
    }
    if sourceCard == self.destinationCardData.selfCard {
      return DropProposal(operation: .cancel)
    }
    var newSortOrder: Card.SO?
    
    if dragonVM.useDropLocationForLeftOrRightInsertion,
       let destLength = destinationCardSize?.forDimension(destinationCardData.axis) {

      var debugSign: String = ""
      // TODO: when building horizontal drawer, this .width & .x will need to flip to .height & .y
      let oldSortOrder = destinationCard.sortOrder
      
      if info.location.x < (destLength/2) {
				newSortOrder = oldSortOrder - Card.SO(0.001) // drop to left of destinationCard
        debugSign = "-"
      } else {
				newSortOrder = oldSortOrder + Card.SO(0.001) // drop to right of destinationCard
        debugSign = "+"
      }
      print("debugSign: \(debugSign)   \(newSortOrder)")
      
    } else {
      // simple insertion-to-left sortOrder
      llog("not using useDropLocationForLeftOrRightInsertion")
      newSortOrder = destinationCard.sortOrder - 0.001
    }
    
    if let newSortOrder {
      
      llog("-- Will update sortOrder --")
			withAnimation(.interactiveSpring()) {
        // dragonVM.sourceCardData?.selfCard.sortOrder = newSortOrder ?? Card.defaultSortOrder
        dragonVM.sourceCardData?.selfCard.sortOrder = newSortOrder

				// Execute code for host app
				sourceCardData?.sourceCardDropUpdated(destinationCard)
				// probably can use animation's transaction to access the animation property is host app needs it
      }
    }
    
    return DropProposal(operation: .move)
  }
  
	func performDrop(info: DropInfo) -> Bool {
		llog("🎉 🎉 🎉 🎉 🎉")
		defer { self.resetDraggingModelAndDelegate() }
		guard let sourceCard = self.sourceCard else {
			llog("⚠️ unexpectedly found no sourceCard")
			return false
		}

		// first save so the dropEntered() changes get saved into persistentStore. Then on background contexts the snapshot function will have updated data to work from



		sourceCardData?.sourceCardPerformDrop(destinationCard)

		// normalize the sortOrder of Cards

		Card.Parent.NormalizeChildrenSortOrder(for: destinationCard.objectParent)

		if destinationCard.objectParent != dragonVM.sourceCardSourceParent {
			Card.Parent.NormalizeChildrenSortOrder(for: dragonVM.sourceCardSourceParent)
		}


		llog("🎉 succeeded")

    // self.resetDraggingModelAndDelegate()
		return true

	}
  
  func validateDrop(info: DropInfo) -> Bool {
    // if destinationCard?.hasCode ?? false {
    //   print("hasItemsConforming:  \(info.hasItemsConforming(to: [UTType.caleoCode, UTType.caleoSnippet] ) )")
    //   return info.hasItemsConforming(to: [UTType.caleoCode, UTType.caleoSnippet] )
    // }
    // if destinationCard?.hasSnippet ?? false {
    //   return info.hasItemsConforming(to: [UTType.caleoSnippet] )
    // }
    return false
  }
  
  func dragInProgress(info: DropInfo) {
    if dragonVM.inProgressOverCardID.isNil {
			// draggingVM.sourceCard = draggingVM.startingSourceCard
      // dragonVM.inProgress = true
			dragonVM.inProgressOverCardID = destinationCard.objectID //dragonVM.sourceCardData?.selfCard.objectID

    }
  }
  
  func resetDraggingModelAndDelegate() {
    dragonVM.sourceCardData = nil
    dragonVM.sourceCardSourceParent = nil
		dragonVM.inProgressOverCardID = sourceCard?.objectID
  }
}
