//
//  File.swift
//  
//
//  Created by cms on 3/1/22.
//

import Foundation
import SwiftUI
import Combine
import AdAstraExtensions

#if DEBUGXX


class KangarooScrollView_viaSwiftUI_ViewModel: ObservableObject, KSVScrollVCDelegate {
	static let ScrollingCompletedSeconds = 0.2
	init(ksvScrollManager: KSVScrollManager) {
		self.ksvScrollManager = ksvScrollManager
		ksvScrollManager.scrollVCDelegate = self
	}

	var ksvScrollManager: KSVScrollManager
	func move(){
		
	}
	func move(_ deltaShift: CGFloat) {
		// 	paneCenterPointAnchorInContent = paneCenterInContent + deltaShift
		//
		// 	scrollEndedDetector.send(rawContentRect) // send now so that scrollEnded() will eventually be called, even if scrollView doesn't move on .scrollTo() because it's already on correct position. (lacking this results in stableScrollInProgress being persistently active upon starting if start position is the correct position.)
		//
		// 	withAnimation {
		// 		primaryScrollViewProxy.scrollTo(primaryAnchorID, anchor: .center)
		// 	}
	}

	@Published var paneCenterPointAnchorInContent: CGFloat = .zero

}

struct KangarooScrollView_viaSwiftUI<Content: View>: View {
	@EnvironmentObject var ksvC: KSVScrollManager
	@EnvironmentObject var gvm: KangarooScrollViewGenericViewModel

	@StateObject var vm: KangarooScrollView_viaSwiftUI_ViewModel
	var wrappedContent: (KangarooScrollViewProxy) -> Content


	init(ksvScrollManager: KSVScrollManager,
			 wrappedContent: @escaping (KangarooScrollViewProxy) -> Content ){
		self._vm = StateObject(wrappedValue:
														KangarooScrollView_viaSwiftUI_ViewModel( ksvScrollManager: ksvScrollManager ))
		self.wrappedContent = wrappedContent


		// Setup Scrolling Detector:
		let scrollEndedDetector: CurrentValueSubject<CGRect?, Never> = CurrentValueSubject<CGRect?, Never>(nil)
		let scrollEndedPublisher: AnyPublisher<CGRect?, Never> =
			scrollEndedDetector
			// .dropFirst()
				.debounce(for: ScrollingCompletedDelay, scheduler: DispatchQueue.main)
			// .last()
			// .dropFirst()
				.eraseToAnyPublisher()

		self.scrollEndedDetector = scrollEndedDetector
		self.scrollEndedPublisher = scrollEndedPublisher


		// // Setup Frame Resizing Detector:
		// let paneResizedDetector = CurrentValueSubject<CGSize?, Never>(nil) //(CGSize(w: -1, h: -1))
		// let paneResizedPublisher: AnyPublisher<CGSize?, Never> =
		// 	paneResizedDetector
		// 	// .dropFirst() //to drop the initial value CGSize(w: -1, h: -1)
		// 		.debounce(for: PaneResizingCompletedSeconds, scheduler: DispatchQueue.main)
		// 		.eraseToAnyPublisher()
  //
		// self.paneResizedDetector = paneResizedDetector
		// self.paneResizedPublisher = paneResizedPublisher
  //

		// Setup Scrolling Velocity Detector:
		let scrollVelocityDetector = CurrentValueSubject<CGFloat, Never>(CGFloat(0))
		let scrollVelocityPublisher: AnyCancellable = {
			scrollVelocityDetector
			// .dropFirst()
				.scan((time: DispatchTime.now(), position: CGFloat.zero, rate: Optional<Double>(nil) )){ lastResult, position in

					let now = DispatchTime.now()
					let interval = (lastResult.time.distance(to: now)).asDouble()
					let distance: Double  = position - lastResult.position
					let rate =  interval.isNotNil ? abs(distance/interval!) : nil
					//print("🚅\(rate.dd)", terminator: "\n")
					return (time: now, position: position, rate: rate)
				}
			// .eraseToAnyPublisher()
				.sink{ interval in
					// interval.timeInterval.self
					// print("🚅\(interval.magnitude)", terminator: "\n")
					// print("Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)")
				}
		}()
		self.scrollVelocityDetector = scrollVelocityDetector
		self.scrollVelocityPublisher = scrollVelocityPublisher




	}
	var direction: Axis.Set { ksvC.direction }


	let ScrollingCompletedDelay = DispatchQueue.SchedulerTimeType.Stride.seconds(KangarooScrollView_viaSwiftUI_ViewModel.ScrollingCompletedSeconds)
	// let PaneResizingCompletedSeconds = DispatchQueue.SchedulerTimeType.Stride.seconds(0.5)

	// Setup Scrolling Detector:
	let scrollEndedDetector: CurrentValueSubject<CGRect?, Never>
let scrollEndedPublisher: AnyPublisher<CGRect?, Never>

	// // FrameResizing:
	// let paneResizedDetector: CurrentValueSubject<CGSize?, Never>
	// let paneResizedPublisher: AnyPublisher<CGSize?, Never>


	// Setup Scrolling Velocity Detector:
	let scrollVelocityDetector: CurrentValueSubject<CGFloat, Never>
	let scrollVelocityPublisher: AnyCancellable

	// using Combine for detecting end of change:
	// https://stackoverflow.com/questions/65062590/swiftui-detect-when-scrollview-has-finished-scrolling


	@State var primaryScrollViewID: String = "KangarooScrollView_" + UUID().uuidString
	var primaryAnchorID: String { "PrimaryAnchorID_\(self.primaryScrollViewID)" }
	var wrappedContentID: String { "WrappedContentID_\(self.primaryScrollViewID)" }

	@State var PrimaryScrollViewProxy: ScrollViewProxy? // make accessible outside of ScrollView


	var body: some View {
		// Color.systemGreen
		ScrollViewReader { primaryScrollViewProxy in
			ScrollView(gvm.scrollableDirection, showsIndicators: gvm.showsIndicators){
				AStack(direction){

					Spacer() // underscrolling
					// .aframe(direction, underScrollLength )
					.aframe(direction, 0 )


					// 		// Full-length content
					wrappedContent(
						KangarooScrollViewProxy(
							scrollToCenterAnchorAction: {},
							startStableScrollAction: {},
							selectedStoplight: $ksvC.selectedStoplight)              )
					// content can be larger than or smaller than the KSV frame
					.id(wrappedContentID)

					// AnchorRectangle
					// .overlay( primaryAnchor() )
					.overlay( debugAnchors(for: .divot) )
					.overlay( selectedStoplightDivotDebugAnchor() )

					//
					.background( // changes in content geometry frame (e.g. any scrolling)
						GeometryReader { scrollContentGeometryProxy in
							Color.clear
								.onAppear{
									let rawContentRect = scrollContentGeometryProxy.frame(in: .named(primaryScrollViewID))
									updateTrackingContentFrame(with: rawContentRect)
								}
								.onChange(of: scrollContentGeometryProxy.frame(in: .named(primaryScrollViewID))) { newContentRect in
									// 	// using scrollViewID coordinateSpace makes this content frame relative to the outer frame, and therefore movement of this frame is scrolling
									updateTrackingContentFrame(with: newContentRect)
									// 	vm.rawContentRect = newContentRect
									// 	vm.contentSize = newContentRect.size
									// 	self.scrollingContent(to: newContentRect)
								}

						}
					)


					Spacer() // overscrolling
						// .aframe(direction, overScrollLength )
						.aframe(direction, 0 )
				}
				.overlay( primaryAnchor() )
				// .onChange(of: $ksvC.paneCenterInContent){
				// 	paneCenterPointAnchorInContent = paneCenterInContent + deltaShift
    //
				// 	scrollEndedDetector.send(rawContentRect) // send now so that scrollEnded() will eventually be called, even if scrollView doesn't move on .scrollTo() because it's already on correct position. (lacking this results in stableScrollInProgress being persistently active upon starting if start position is the correct position.)
    //
				// 	withAnimation {
				// 		primaryScrollViewProxy.scrollTo(primaryAnchorID, anchor: .center)
				// 	}
				// }
			}
			.background( // changes in pane geometry size (e.g. resizing)
				GeometryReader { paneGeometryProxy in
					Color.clear
						.onAppear{
							let newPaneSize = paneGeometryProxy.size
							updateTrackingPaneSize(with: newPaneSize)
						}
						.onChange(of: paneGeometryProxy.size){ newPaneSize in
							// any change in scrollFrame's size will also change scrollContent's relative frame and call for its update too
							// ignoring '.frame' changes because change in x,y is not relevant.
							updateTrackingPaneSize(with: newPaneSize)
						}
#if DEBUG
						.onChange(of: paneGeometryProxy.frame(in: .global)){ newFrame in
							llog("paneGeometryProxyFrame: \(newFrame)")
						}
#endif
				}
			)
			.onAppear{
				llog("KSV Appear")
				PrimaryScrollViewProxy = primaryScrollViewProxy
			}
		}
#if DEBUG
		.overlay( debugAnchors(for: .notch) )
		.overlay( selectedStoplightNotchDebugAnchor() )
		.overlay( paneCenterDebugAnchor() )
#endif
		// .overlay( buildTelemetry() )
		
		.onReceive(scrollEndedPublisher) { rawContentRect in
			scrollEnded(at: rawContentRect)
		}
		// .onReceive(paneResizedPublisher) { newSize in
		// 	resizingPaneStopped(at: newSize)
		// }
		.coordinateSpace(name: primaryScrollViewID)
		// Notches
		// .animation(.none)
	}

	func updateTrackingPaneSize(with newPaneSize: CGSize){
		// paneResizedDetector.send(newPaneSize)
		ksvC.updateTrackingPaneSize(with: newPaneSize) }

	func resizingPaneStopped(at newSize: CGSize?){
		ksvC.resizingPaneStopped(at: newSize) }

	func updateTrackingContentFrame(with rawContentRect: CGRect){
		scrollEndedDetector.send(rawContentRect)
		ksvC.updateTrackingContentFrame(with: rawContentRect) }

	func scrollEnded(at rawContentRect: CGRect?){
		ksvC.scrollEnded(at: rawContentRect)
	}
}





extension DispatchTimeInterval {
	func asDouble() -> Double? {
		var result: Double? = 0

		switch self {
			case .seconds(let value):
				result = Double(value)
			case .milliseconds(let value):
				result = Double(value)*0.001
			case .microseconds(let value):
				result = Double(value)*0.000001
			case .nanoseconds(let value):
				result = Double(value)*0.000000001

			case .never:
				result = nil
		}

		return result
	}
	// https://stackoverflow.com/questions/47714560/how-to-convert-dispatchtimeinterval-to-nstimeinterval-or-double
}

#endif
