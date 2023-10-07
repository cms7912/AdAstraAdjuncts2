//
//       Draggable Card.swift
//  Caleo
//
//  Created by cms on 5/19/21.
//  Copyright © 2021 CMS. All rights reserved.
//

#if DEBUG_XXXXX
import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers
import os.log

class DraggingCardModel: ObservableObject {
	@Published var sourceCardViewData: Card?
	var sourceCardOriginalParentCode: Code?
	@Published var overCard: Card?
	@Published var inProgress: Bool = false
}

struct DraggableCardView<Content: View>: View, Identifiable {
	@EnvironmentObject var dragging: DraggingCardModel
	@EnvironmentObject var projectManagerViewModel: ProjectManagerViewModel

	@ObservedObject var selfCard: Card
	let id: String

	var content: Content
	var droppableContentUTTypes: [UTType] {
		return [UTType.caleoSnippet]
		if selfCard.hasSnippet {
			if betaFeatures.contains(.nestedCodes) {
				return [UTType.caleoSnippet, UTType.caleoCode]
			} else {
				return [UTType.caleoSnippet]
			}
		} else if selfCard.hasCode {
			if betaFeatures.contains(.nestedCodes) {
				return [UTType.caleoCode]
			} else {
				return []
			}
		} else {
			// New Code Card -- not droppable
			return []
		}
	}
	public init(
		card: Card,
		@ViewBuilder content: () -> Content
	) {
		self.selfCard = card
		self.id = ( card.id ?? UUID() ).uuidString + "forDraggableCardView"
		self.content = content()
	}


	var body: some View {
		if (HighlightDebug.disableCardDragAndDrop) {content
		} else {
			content
			// .opacity( dragging.sourceCard == selfCard && dragging.overCard != selfCard ? 0 : 1 )
#if DEBUG
				.border(
					(HighlightDebug.feature.debugCardDragAndDrop) ? (
						dragging.overCard == selfCard ? (
							Color.green
						)
						:(
							dragging.sourceCard == selfCard
							? Color.blue
							: Color.clear // <- color all other cards will have
							// : Color.green
						)
					)
					:(
						Color.clear
					)
					, width: 2)
				.overlay (
					Group {
					if (HighlightDebug.showSortOrdersOnSnippets) {n
						if selfCard.hasSnippet {
							VStack {
								Text(selfCard.sortOrder2.description)
								Text(selfCard.id?.uuidString ?? "")
									.font(.caption2)
							}
							.background(Color.systemGray)
						}
					}
				}
				)
#endif
			// .overlay( DraggableCardViewOverlay(selfCard: selfCard) )
			// onDrop is possible to selfCard:

				.onDrop(of: droppableContentUTTypes, delegate:
							CardDropDelegate(
								dragging: dragging,
								destinationCard: selfCard,
								PM: projectManagerViewModel.projectManager
							))

			// onDrag this selfCard
				.onDrag {
					dragging.sourceCardViewData = selfCard
					dragging.sourceCardOriginalParentCode = selfCard.snippet?.code ?? selfCard.code?.parentCode
					dragging.inProgress = true
					// return NSItemProvider(object: String(selfCard.objectID.description) as NSString)
					if selfCard.hasCode {
						return NSItemProvider(item: String(selfCard.objectID.description) as NSString, typeIdentifier: UTType.caleoCode.identifier)
					} else if selfCard.hasSnippet {
						return NSItemProvider(item: String(selfCard.objectID.description) as NSString, typeIdentifier: UTType.caleoSnippet.identifier)
					} else {
						// New code card
						// not sure how else this could happen?
						dragging.sourceCardViewData = nil
						dragging.sourceCardOriginalParentCode = nil
						dragging.inProgress = false
						return NSItemProvider(item: nil, typeIdentifier: nil)
					}
				}
		}
	}
}
struct DraggableCardViewOverlay: View {
	@EnvironmentObject var dragging: DraggingCardModel

	@ObservedObject var selfCard: Card

#if DEBUG_X
	// debugging function for showing sortOrder count over each card during drag
	var body: some View {
		if dragging.inProgress && selfCard.hasSnippet && (HighlightDebug.showSortOrdersOnSnippets) {
			return ZStack {
				(dragging.sourceCard == selfCard) ?
				Color.secondarySystemBackground.opacity(0.50)
				: Color.gray.opacity(0.50)
				
				VStack {
					Text(selfCard.sortOrder2.description)
					Text(selfCard.id?.uuidString ?? "")
						.font(.caption2)
				}
			}
		} else {
			return ZStack {
				(dragging.inProgress && dragging.sourceCard == selfCard)
				? Color.secondarySystemBackground
				: Color.clear
				
				VStack {
					Text("")
					Text("")
						.font(.caption2)
				}
				
			}
		}
	}
#else
	var body: some View {
		if dragging.inProgress && dragging.sourceCard == selfCard {
			// return Color.gray.opacity(0.50)
			return Color.clear
		} else {
			return Color.clear
		}
	}
#endif

}
extension UTType {
	static let caleoSnippet: UTType = {
		UTType.init(exportedAs: "app.caleo.snippet", conformingTo: nil)
	}()

	static let caleoCode: UTType = {
		UTType.init(exportedAs: "app.caleo.code", conformingTo: nil)
	}()
}


struct CardDropDelegate: DropDelegate {
	func llog(_ string: String? = nil, function: String = #function) {
			Logger.llog("🐲 \(string ?? "")", function: function)

	}

	let dragging: DraggingCardModel
	var sourceCardViewData: Card? {
		dragging.sourceCardViewData
	}
	var destinationCard: Card? // this card sent this delegate's functions
	var destinationTrayOfCode: Code? // this tray sent this delegate's functions
	static var newestDestinationCard: Card?
	static var newestSortOrder: Double?
	static var maxLocationX: CGFloat?

	var PM: ProjectManager?

	func dropEntered(info: DropInfo) {
		llog("⬇️")
		guard let sourceCardViewData = self.sourceCardViewData else {
			llog("⚠️ failed to get sourceCard")
			return
		}
		dragging.inProgress = true


		if let destinationCode = destinationTrayOfCode {
			// drag is currently over this tray's open area
			llog("🌊 in tray's open area")

			sourceCardViewData.sortOrder2 =  .greatestFiniteMagnitude
			if sourceCardViewData.hasCode {
				sourceCardViewData.code?.parentCode = destinationCode
			} else if sourceCardViewData.hasSnippet {
				sourceCardViewData.snippet?.code = destinationCode
			}
			sourceCardViewData.managedObjectContext?.saveContext()

		} else {
			// drag is currently over a card

			if sourceCardViewData == destinationCard {
				llog("sourceCard == destinationCard")
				// return
			}
			// guard (destinationCard?.hasSnippet ?? false) else {
			//	return
			// }
			// if destinationCard?.hasCode ?? true {
				// not ready to drag-and-drop onto codes yet
			//	return
			// }

			dragging.overCard = destinationCard

			if CardDropDelegate.newestDestinationCard != destinationCard {
				// now on a different destination card
				CardDropDelegate.newestDestinationCard = destinationCard
				// CardDropDelegate.maxLocationX = nil
				CardDropDelegate.maxLocationX = info.location.x
				llog("updated maxLocationX to: \(CardDropDelegate.maxLocationX?.description ?? "")")
			}
		}
	}

	func dropExited(info: DropInfo) {
		llog("⬆️")

		if dragging.overCard == destinationCard {
			llog("will invalidate dragging.overCard")
			dragging.overCard = nil
			// validates assumption that on dropExit the destinationCard needs to removed itself from dragging.overCard.
			// but does not assume that dropExited called before a new card's dropEntered was called and set the .overCard value
		}
	}

	func dropUpdated(info: DropInfo) -> DropProposal? {
		// llog()
		dragging.inProgress = true
llog("""

inProgress: \(dragging.inProgress)
sourceCard: \(dragging.sourceCardViewData?.sortOrder2.description ?? "")
sourceCard: \(dragging.sourceCardViewData?.id?.uuidString ?? "")
overCard: \(dragging.overCard?.sortOrder2.description ?? "")
overCard: \(dragging.overCard?.id?.uuidString ?? "")
""")

		guard let destinationCard = self.destinationCard else {
			NSObject.CrashAfterUserAlert("why would dropDelegate not receive the destinationCard, aka self.card")
		}
		// guard (destinationCard.hasSnippet ) else { return  DropProposal(operation: .forbidden) }

		// if destinationCard != dragging.overCard {
			// llog("❓ why would this happen?")
		// }
		dragging.overCard = destinationCard

		if destinationCard == sourceCardViewData {
			llog("destinationCard is sourceCard")
			return DropProposal(operation: .move)
		}
		// if destinationCard.hasCode {
		// Logger.llog("⚠️ unexpectedly received a drop via a destinationCard with a code")
		// 	return DropProposal(operation: .forbidden)
		// }

		CardDropDelegate.maxLocationX = max(CardDropDelegate.maxLocationX ?? 0, info.location.x)

		if let sourceCardViewData = self.sourceCardViewData {
			// let newCode = destinationCard.code ?? destinationCard.snippet?.code {
			let newCodeForDestination = destinationCard.snippet?.code ?? destinationCard.code

			var newSortOrder = destinationCard.sortOrder2

			var debugSign: String = ""
			let minimumSliver: CGFloat = 10
			// if info.location.x < max(50, (CardDropDelegate.maxLocationX ?? 100)/2) {
			if info.location.x < max(minimumSliver, (CardDropDelegate.maxLocationX ?? minimumSliver*2)/2) {
				newSortOrder -= 0.001 // drop to left of destinationCard
				debugSign = "-"
			} else {
				newSortOrder += 0.001 // drop to right of destinationCard
				debugSign = "+"
			}

			Logger.llog(if: true, """
D:\(CardDropDelegate.newestDestinationCard?.sortOrder2.description ?? "")
maxX:\(CardDropDelegate.maxLocationX?.description ?? "nil")
iX:\(info.location.x.rounded(.toNearestOrEven))  (\(debugSign)
iY:\(info.location.y.rounded(.toNearestOrEven))  (\(debugSign)
""")

			// print("Global center: \(geo.frame(in: .global).midX) x \(geo.frame(in: .global).midY)")
			// print("Custom center: \(geo.frame(in: .named("Custom")).midX) x \(geo.frame(in: .named("Custom")).midY)")
			// print("Local center: \(geo.frame(in: .local).midX) x \(geo.frame(in: .local).midY)")

			if CardDropDelegate.newestSortOrder != newSortOrder {
				CardDropDelegate.newestSortOrder = newSortOrder
				llog("-- Will update sortOrder data --")
				withAnimation(.interactiveSpring()) {
					// sourceCard.sortOrder2 = newSortOrder - 0.001
					sourceCardViewData.sortOrder2 = newSortOrder
					if sourceCardViewData.hasCode {
						// sourceCard.code?.parentCode = newCodeForSnippet
						if destinationCard.hasCode {
							sourceCardViewData.code?.parentCode = destinationCard.code?.parentCode
						} else {
							sourceCardViewData.code?.parentCode = newCodeForDestination
						}
					} else if sourceCardViewData.hasSnippet {
						sourceCardViewData.snippet?.code = newCodeForDestination
					}
					sourceCardViewData.managedObjectContext?.saveContext()
					// sourceCard.managedObjectContext?.saveContextAndWait()
				}
			}
		} else {
			llog("⚠️ unexpectedly found no self.sourceCard")
		}
		return DropProposal(operation: .move)
	}

	func performDrop(info: DropInfo) -> Bool {
		llog("🎉 🎉 🎉 🎉 🎉")

		guard let sourceCardViewData = self.sourceCardViewData else {
			self.resetDraggingModelAndDelegate()
			llog("⚠️ unexpectedly found no sourceCard")
			return false
		}
		// first save so the dropEntered() changes get saved into persistentStore. Then on background contexts the snapshot function will have updated data to work from
		sourceCardViewData.managedObjectContext?.saveContextAndWait()

		// Update snapshot if card has a snippet
		if let snippetOfSourceCard = sourceCardViewData.snippet {
			PM?.updateSnapshotOf(snippetObjectID: snippetOfSourceCard.objectID)
		}

		let newParentCode: Code? = destinationCard?.code ?? destinationCard?.snippet?.code
		// okay for newParentCode to be nil. This represents root-level codes without parents

		// normalize the sortOrder2 of Cards
		llog("Will also normalize new parentCode")
		 Card.NormalizeSortOrder(for: newParentCode)
		if newParentCode != dragging.sourceCardOriginalParentCode {
			llog("Will also normalize source parentCode")
			// changed codes from source card's original code. So also normalize the original parentCode
			Card.NormalizeSortOrder(for: dragging.sourceCardOriginalParentCode)
		}

		self.resetDraggingModelAndDelegate()

		llog("🎉 succeeded")
		return true

	}

	func validateDrop_DISCONNECTED (info: DropInfo) -> Bool {
		if destinationCard?.hasCode ?? false {
			return info.hasItemsConforming(to: [UTType.caleoCode] )
		}
		if destinationCard?.hasSnippet ?? false {
			return info.hasItemsConforming(to: [UTType.caleoCode, UTType.caleoSnippet] )
		}
		return false
	}


	func validateDrop(info: DropInfo) -> Bool {
// return true
		return info.hasItemsConforming(to: [UTType.caleoCode, UTType.caleoSnippet] )
	}


	func resetDraggingModelAndDelegate() {
		dragging.sourceCardViewData = nil
		dragging.sourceCardOriginalParentCode = nil
		dragging.overCard = nil
		dragging.inProgress = false
		CardDropDelegate.newestDestinationCard = nil
		CardDropDelegate.maxLocationX = nil
	}
}
                                                      
                                                      
#endif
