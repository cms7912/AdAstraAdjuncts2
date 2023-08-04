//
//  File.swift
//  
//
//  Created by cms on 2/10/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions
#if DEBUG_XX
internal var KSVDebug_AnchorSize: CGFloat = 0

extension KangarooScrollView_viaSwiftUI{

	func buildTelemetry() -> some View {
		ZStack(alignment: .bottom){
			Color.clear
			if KSVDebugMode {
				GroupBox{
          Text("contentOffset: \(ksvC.rawContentOffset.dd)")
					// Text("frameSize: \(frameSize.dd)")
          Text("paneCenterPoint: \(ksvC.paneCenterPoint.dd)")
          Text("paneCenterInContent: \(ksvC.paneCenterInContent.dd )")
          Text("paneCenterPointAnchorInContent: \(vm.paneCenterPointAnchorInContent.dd)")
          Text("Notch in Frame: \((ksvC.selectedStoplight?.notchPosition).dd)")
#if DEBUG
          Text("Notch in Content: \((ksvC.notchPositionInContentFrame).dd) ")
#endif
          Text("Divot in Content: \((ksvC.selectedStoplight?.divotPosition).dd)")
					// Text("offsetAtHeader: \(offsetAtHeader.description)")
					// Text("offsetAtFooter: \(offsetAtFooter.description)")
				}
				.font(.caption2)
			}
		}
	}


	struct AnchorRectangle2: View {
		internal init(
			direction: Binding<Axis.Set>,
			position: Binding<CGFloat>,//? = nil,
			// kp: KangarooPosition? = nil,
			positionOffset: CGFloat = 0,
			id: String,
			gradientColors: [Color] = [.clear],
			fill: Color = .clear,
			border: Color = .clear, //.white.opacity(0.50),
			borderWidth: CGFloat = 0) {

				self._direction = direction
				self._position = position
				self.positionOffset = positionOffset

				self.id = id
				self.gradientColors = gradientColors
				self.fillColor = fill
				self.borderColor = border
				self.borderWidth = borderWidth
			}

		@Binding var direction: Axis.Set
		@Binding var position: CGFloat
		var positionOffset: CGFloat
		// @ObservedObject var kp: KangarooPosition
		@State var id: String
		let gradientColors: [Color]
		let fillColor: Color
		let borderColor: Color
		let borderWidth: CGFloat
		@State var offDirectionLength: CGFloat = 0


		var body: some View {
			ZStack(alignment: .leading){
				Color.clear
				AStack(direction){
				Spacer()
				.aframe(direction, max(0, position + positionOffset - (KSVDebug_AnchorSize/2)))
				Rectangle()
					.fill( fillColor )
					.id(id)
					.aframe(direction, KSVDebug_AnchorSize)
					.overlay(
						LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing) )
					.border(borderColor, width: borderWidth)
					// .readSize{size in
					// 	offDirectionLength = size.forDimension(direction.opposite)
					// }
					// .border(id.prefix(7) == "Primary" ? AdAstraColor.magenta.system : Color.clear, width: 3)
				// .position(CGPoint(direction, position, offDimensionSize: offDirectionLength))  // anchors are half off-view because this .position is putting center point at .zero on opposite-direction axis.
					// .padding(.leading, position)
// - .padding does not work.  causes weird bugs that simply scrolling will change the padding offset.
					// - .position works for location. But .position greedly examples to full parent view size, and then centering on .id() goes to the center of full parent view (e.g. center of scrollView, always).
					// - Spacer() seems heavy handed, but accurately gets results.  During debugging its a lot with many visual anchors, but during release builds there will only be a single primaryAnchor() being positioned.
				Spacer()
				}
			}
		}
	}
	// uses a precise frame dimension on 'spacer()' to position AnchorRectangle where needed.



	func primaryAnchor() -> some View {
			AnchorRectangle2(
				direction: $ksvC.direction,
        position: $vm.paneCenterPointAnchorInContent,
				// positionOffset: underScrollLength,
				id: primaryAnchorID,
				fill: Color.systemRed.opacity( 0.5 )
			)
	}

	func paneCenterDebugAnchor() -> some View {
		Group{
      if ksvC.paneCenterPoint.isNotNil, KSVDebugMode.isTrue {
				AnchorRectangle2(
					direction: $ksvC.direction,
          position: .constant(ksvC.paneCenterPoint!),
					// kp: notch,
					id: UUID().uuidString + "PaneCenterAnchor",
					fill: Color.clear,
					border: Color.systemRed.opacity(0.50),
					borderWidth: 2
				)
				// } else {
				// 	EmptyView()
			}

		}

	}

	func selectedStoplightNotchDebugAnchor() -> some View {
		// ZStack{ Color.clear
		Group{
      if (ksvC.selectedStoplight?.notchPosition).isNotNil, KSVDebugMode.isTrue {
				AnchorRectangle2(
					direction: $ksvC.direction,
          position: ksvC.selectedStoplight!.notchPositionBinding, // .constant(notch),
					// kp: notch,
					id: UUID().uuidString + "SelectedNotchAnchor",
					fill: Color.clear,
					border: AdAstraColor.white.system.opacity(0.50),
					borderWidth: 2
				)
			// } else {
			// 	EmptyView()
			}

		}
	}


	func selectedStoplightDivotDebugAnchor() -> some View {
		Group{
      if (ksvC.selectedStoplight?.divotPosition).isNotNil, KSVDebugMode.isTrue {
				 AnchorRectangle2(
					direction: $ksvC.direction,
          position: ksvC.selectedStoplight!.divotPositionBinding, //.constant(divot),
          // kp: divot,
					id: UUID().uuidString + "SelectedDivotAnchor",
					// fill: AdAstraColor.white.system.opacity(0.50)
					border: AdAstraColor.white.system.opacity(0.50),
					borderWidth: 2
				 )
			// } else {
			// 	EmptyView()
			}
		}
	}

	enum StopElement{
		case notch
		case divot
		var isNotch: Bool { self == .notch }
		var anchorColor: Color {
			self.isNotch ?
			AdAstraColor.oceanBlue.system.opacity(0.00) :
			AdAstraColor.green.system.opacity(0.50)

		}
		var anchorGradient: [Color] {
			if self.isNotch { return [
				AdAstraColor.forestGreen.system.opacity(0.75),
				AdAstraColor.forestGreen.system.opacity(0.75),
				Color.clear,
				AdAstraColor.forestGreen.system.opacity(0.75),
				AdAstraColor.forestGreen.system.opacity(0.75),
			] } else { return [
				Color.clear,
				AdAstraColor.forestGreen.system.opacity(0.75),
				AdAstraColor.forestGreen.system.opacity(0.75),
				Color.clear
			] } }
	}
	func debugAnchors(for elementRequested: StopElement) -> some View {
		// Group{
		ZStack(alignment: .center){
			// 	Group{
			// 		if elementRequested.isNotch {
			// 			Color.clear
			// 		} else {
			// 			// Color.gray.opacity(0.50)
			// 			Color.clear
			// 		}
			// 	}
      if ksvC.KangarooMapArray.isNotEmpty, KSVDebugMode.isTrue {
				ForEach(ksvC.KangarooMapArray, id: \.mapID){ map in

					ForEach( positions(in: map, for: elementRequested), id:\.self ){ position in

						Color.clear
							.overlay(

								AnchorRectangle2(
									direction: $ksvC.direction,
									position: Binding(getOnly: {[weak position] in position}),
									// kp: element,
									id: "DebugAnchor\(position)",
									//gradientColors: elementRequested.anchorGradient,
									fill: elementRequested.anchorColor
									// border: Color.systemGreen,
									// borderWidth: 2
								)
							) // putting many anchors in a single overlay causes bug of slightly-wrong positions when using Spacer().frame() in AnchorRectangle. But putting every anchor in its own overlay here resolves that issue of slightly incorrect positioning.
					}
					//Text("*\(elements.count)**")
				}
			}
			//Text("*\(KangarooMapArray!.count)*")

			//		AnchorRectangle2(
			//			direction: $direction,
			//			position: Binding(get: {CGFloat(300)}, set: {_ in }), //element.actualPositionBinding,
			//			id: "debuganchor",
			//			border: Color.systemBlue,
			//			borderWidth: 1
			//			//element.id + "DebugAnchor",
			//			// gradientColors: elementRequested.anchorGradient)
			//		)
			// }

		}
	}

	func positions(in map: any Map, for elementRequested: StopElement) -> [CGFloat] {
		var positions = [CGFloat]()
		var index = 0
		while let position = (elementRequested.isNotch ? map[notchIndex: index] : map[divotIndex: index]) {
			positions.append(position)
			index += 1
		}
return positions
	}
}
#endif
