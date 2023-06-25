//
//  Share Sheet.swift
//  Caleo
//
//  Created by cms on 4/30/21.
//  Copyright © 2021 CMS. All rights reserved.
//

import Foundation
import SwiftUI
// import AdAstraBridgingByShim




public struct ShareSheetUI: View {

	@State var shareItems: [Any]

	@State var activeSheetDismiss: () -> Void

	public init(shareItems: [Any], activeSheetDismiss: @escaping () -> Void = {} ) {
		self.shareItems = shareItems
		self.activeSheetDismiss = activeSheetDismiss
	}

	public var body: some View {
		VStack {
			ShareSheetRepresentable(shareItems: shareItems)
		}
	}
	// adapted from: https://developer.apple.com/forums/thread/127756
}

#if os(iOS)

struct ShareSheetRepresentable: UIViewControllerRepresentable {

	typealias UIViewControllerType = UIActivityViewController

	@State var shareItems: [Any]

	init(shareItems: [Any]) {
		self.shareItems = shareItems
	}

	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController( activityItems: shareItems, applicationActivities: nil )
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
		
	}



}
// class ShareSheetRepresentableCoordinator: NSObject, NSSharingServicePickerDelegate {
// 	var parentRepresentable: ShareSheetRepresentable
// 	var shareItems: [Any] = .empty
// 	init(parentRepresentable: ShareSheetRepresentable, shareItems: [Any]) {
// 		self.parentRepresentable = parentRepresentable
// 	}
// 	func showDialog(){
// 		guard shareItems.isNotEmpty else { return }
// 		let sharingPicker = NSSharingServicePicker(items: shareItems)
// 		if let destinationView = NSApplication.shared.windows.first?.contentView {
// 			sharingPicker.delegate = self
// 			sharingPicker.show(
// 				relativeTo: NSRect(x: destinationView.frame.midX,
// 													 y: destinationView.frame.midY,
// 													 width: 0,
// 													 height: 0),
// 				of: destinationView,
// 				preferredEdge: .minY)
// 		}
// 	}
// 
// }

#elseif os(macOS)


struct ShareSheetRepresentable: NSViewControllerRepresentable {
	typealias NSViewControllerType = NSViewController


	@State var shareItems: [Any]

	init(shareItems: [Any]){
		self.shareItems = shareItems
	}

	func makeNSViewController(context: Context) -> NSViewController {
		 NSViewController()
	}
	func updateNSViewController(_ uiViewController: NSViewController, context: Context) { }

	func makeCoordinator() -> ShareSheetRepresentableCoordinator {
		ShareSheetRepresentableCoordinator(parentRepresentable: self, shareItems: shareItems)
	}

}
class ShareSheetRepresentableCoordinator: NSObject, NSSharingServicePickerDelegate {
	var parentRepresentable: ShareSheetRepresentable
	var shareItems: [Any] = .empty
	init(parentRepresentable: ShareSheetRepresentable, shareItems: [Any]) {
		self.parentRepresentable = parentRepresentable
	}
	func showDialog(){
		guard shareItems.isNotEmpty else { return }
		let sharingPicker = NSSharingServicePicker(items: shareItems)
		if let destinationView = NSApplication.shared.windows.first?.contentView {
			sharingPicker.delegate = self
			sharingPicker.show(
				relativeTo: NSRect(x: destinationView.frame.midX,
													 y: destinationView.frame.midY,
													 width: 0,
													 height: 0),
				of: destinationView,
				preferredEdge: .minY)
		}
	}

}

// class UIViewController: NSViewController {
// 	var coordinator: ShareSheetRepresentableCoordinator?
//
// 	override func viewDidAppear() {
// 		coordinator?.showDialog()
// 	}
// }

#endif

