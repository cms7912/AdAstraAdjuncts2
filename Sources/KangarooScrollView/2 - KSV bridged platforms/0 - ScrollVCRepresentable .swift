//
//  File.swift
//  
//
//  Created by cms on 3/23/22.
//

import Foundation
import SwiftUI
// import AdAstraBridgingByMask
import AdAstraBridgingByShim

struct KangarooScrollViewOnPlatform<Content: View>: View {
	@EnvironmentObject var ksvC: KSVScrollManager
	@EnvironmentObject var gvm: KangarooScrollViewGenericViewModel

	var wrappedContent: (KangarooScrollViewProxy) -> Content
	var body: some View {
		KSV_ViewControllerRepresentable<Content>(
			ksvProxy:
				KangarooScrollViewProxy(
					ksvScrollManager: ksvC,
					scrollToCenterAnchorAction: { },
					startStableScrollAction: {  ksvC.clientRequestedStableScroll = true },
					selectedStoplight: $ksvC.selectedStoplight
				),
			ksvScrollManager: self.ksvC,
			gvm: self.gvm,
			wrappedView: wrappedContent
		)
	}
}

struct KSV_ViewControllerRepresentable<Content: View>: UINSViewControllerRepresentable {

	typealias NSViewControllerType = KSV_ScrollViewController<Content>


	@State var ksvProxy: KangarooScrollViewProxy
	@ObservedObject var ksvScrollManager: KSVScrollManager
	@ObservedObject var gvm: KangarooScrollViewGenericViewModel
	var wrappedView: (KangarooScrollViewProxy) -> Content

	func makeViewController(context: Context) -> KSV_ScrollViewController<Content> {
		let viewController = KSV_ScrollViewController<Content>(
			ksvScrollManager: ksvScrollManager,
			gvm: gvm,
			ksvProxy: $ksvProxy,
			wrappedView: wrappedView,
			context.coordinator
		)
		return viewController
	}

	func updateViewController(_ viewController: KSV_ScrollViewController<Content>, context: Context) {
		// none yet
		// viewController.view.invalidateIntrinsicContentSize()
	}

	func makeCoordinator() -> KSV_RepresentableCoordinator<Content> {
		KSV_RepresentableCoordinator(self)
	}
}

class KSV_RepresentableCoordinator<Content: View>: NSObject {
	var parentRepresentable: KSV_ViewControllerRepresentable<Content>
	init(_ parentRepresentable: KSV_ViewControllerRepresentable<Content>) {
		self.parentRepresentable = parentRepresentable
	}
}


