//
//  File.swift
//  
//
//  Created by cms on 5/2/22.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AdAstraBridgingByShim

import AdAstraExtensions


import SwiftUI


struct StealthViewsController<Content: View>: UINSViewControllerRepresentable {
	typealias ViewControllerType = StealthViewsHostingController<Content>
	var wrappedView: Content

	func makeViewController(context: Context) -> ViewControllerType {
		StealthViewsHostingController(rootView: wrappedView) }

	func updateViewController(_ viewController: ViewControllerType, context: Context) { }
}
// class UINSViewControllerRepresentableCoordinator<Content: View>: NSObject {
// 	var parentRepresentable: ShareSheet.ViewControllerType
// 	init(_ parentRepresentable: ShareSheet.ViewControllerType) {
// 		self.parentRepresentable = parentRepresentable
// 	}
// }






class StealthViewsHostingController<Content: View>: UINSHostingController<Content> {


	override init(rootView: Content) {
		super.init(rootView: rootView)

#if os(iOS)
    guard let groundView = self.view else { return }
#elseif os(macOS)
    let groundView = self.view
#endif
		let stealthView = StealthView()
		self.view = stealthView
		stealthView.addSubviewWithAnchorConstraints(groundView)

	}

	@MainActor required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
  /*
	override func loadView() {
		super.loadView()

    guard let groundView = self.view else { return }

		// create stealthView and wrap the ground view inside it
		let stealthView = StealthView()
		self.view = stealthView
		stealthView.addSubviewWithAnchorConstraints(groundView)
	}
*/
}


public class StealthView: UINSView {
	var evasiveViews = [ UINSView: [UINSView] ]()
	// key: view that contains one or more views that should be ignored (evaded)
	// value: array of views that are allowed, within the key view


#if os(iOS)
  public override func hitTest(_ point: CGPoint, with event: UINSEvent?) -> UINSView? {
		self.stealthHitTest(point, with: event)
	}
#elseif os(macOS)
	public override func hitTest(_ point: CGPoint) -> UINSView? {
		self.stealthHitTest(point, with: nil)
	}
	func hitTest(_ point: CGPoint, with event: UINSEvent) -> UINSView? {
		super.hitTest(point)
	}
#endif


		public func stealthHitTest(_ point: CGPoint, with event: UINSEvent?) -> UINSView? {
//#if os(iOS)
      guard let hitView = super.hitTest(point, with: event) else { return nil }
//#elseif os(macOS)
//      guard let hitView = super.hitTest(point) else { return nil }
//#endif

		// test every key view
		for evasiveView in evasiveViews {

			if hitView.isDescendant(of: evasiveView.key) {
				// hitView is within the evasiveView.key

				if let foundView =
						(evasiveView.value.last{ testView in
							hitView.isDescendant(of: testView) })
				{
					// hitView is also within an allowed evasiveView.value
					llog("returning allowed target within evasive view")
					return hitView
				}
				// Found an evasiveView.key that is not descendant of evasiveView.value. Need to find another view to hit.

				// Cycle upward through 'elderRelative' views
				var newTestHitView: UINSView? = evasiveView.key.elderRelative
				while let testHitView = newTestHitView,
							newTestHitView != self {

					// hitTest the testHitView and return it's results if successful.
					 if let result = testHitView.hitTest( self.convert(point, to: testHitView), with: event) {
					//if let result = testHitView.hitTest( self.convert(point, to: testHitView)) {
						llog("returning alternate target after skipping evasive view")
						return result
					}
					// failed to find new hitView, go around again
					newTestHitView = testHitView.elderRelative
				}
				// never found a hit test for this evasiveView.
				llog("returning StealthView")
				return self
			}
		}
		llog("returning native hitView")
		return hitView
	}

}




extension UINSView {
	func stealthKSV_RegisterToEvade(_ key: UINSView, ifNotIn value: [UINSView]){
		if let self = self as? StealthView {
			self.evasiveViews.updateValue(value, forKey: key)
			return
		}
		superview?.stealthKSV_RegisterToEvade(key, ifNotIn: value)
	}

	var elderSibling: UINSView? {
		superview?.subviews.itemBefore(self)
	}
	var elderRelative: UINSView? {
		superview?.subviews.itemBefore(self) ?? superview?.elderRelative
	}

}
