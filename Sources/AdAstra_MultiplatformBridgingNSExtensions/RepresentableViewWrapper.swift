//
//  RepresentableViewWrapper.swift
//  RepresentableViewWrapper
//
//  Created by cms on 10/20/21.
//

import Foundation
import SwiftUI
// import UIKit
#if canImport(AdAstraBridgingByMask)
import AdAstraBridgingByMask
import AdAstraBridgingNSExtensions
#endif

//@available(iOS 999,*)
@available(macOS 999, iOS 999,*)
struct ControllerRepresentable<Content: View>: UIViewControllerRepresentable {

	typealias UIViewControllerType = SwiftViewWrapper<Content>
	typealias NSViewControllerType = SwiftViewWrapper<Content>

	var wrappedView: () -> Content

	func makeUIViewController(context: Context) -> SwiftViewWrapper<Content> {
		let uiViewController = SwiftViewWrapper<Content>(wrappedView: wrappedView, context.coordinator)
		uiViewController.updateContentSize()
		return uiViewController
	}
	func makeNSViewController(context: Context) -> SwiftViewWrapper<Content> {
		self.makeUIViewController(context: context)
	}

	func updateUIViewController(_ uiViewController: SwiftViewWrapper<Content>, context: Context) {
		uiViewController.updateContentSize()
	}
	func updateNSViewController(_ uiViewController: SwiftViewWrapper<Content>, context: Context) {
		self.updateUIViewController(uiViewController, context: context)
	}

	func makeCoordinator() -> ControllerRepresentableCoordinator<Content> {
        ControllerRepresentableCoordinator(parentRepresentable: self)
	}
}
@available(iOS 999,*)
class ControllerRepresentableCoordinator<Content: View>: NSObject {
	var parentRepresentable: ControllerRepresentable<Content>
	init(parentRepresentable: ControllerRepresentable<Content>) {
		self.parentRepresentable = parentRepresentable
	}
}



@available(iOS 999,*)
class SwiftViewWrapper<Content: View>: UIViewController, ObservableObject {

	var wrappedView: () -> Content
	var coordinator: ControllerRepresentableCoordinator<Content>
	init(
		// @ViewBuilder
		wrappedView: @escaping () -> Content, _ coordinator: ControllerRepresentableCoordinator<Content>){
			self.wrappedView = wrappedView
			self.coordinator = coordinator
			super.init(nibName: nil, bundle: nil)
		}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	lazy var uiHostingViewController: UIHostingController = {
		UIHostingController(
			rootView:
				// CardStackAccumulator(dataPackage: dataPackage, wrapper: self)
			// .fixedSize()
			// self.coordinator.parentRepresentable.wrappedView
			wrappedView()
			// .border(Color.red, width: 3)
		)
	}()

	// weak var coordinator: ControllerRepresentable.Coordinator?

	override func viewDidLoad() {
		super.viewDidLoad()

		addChild(uiHostingViewController)
		if #available(iOS 999, *) {
		// view.addSubviewWithAnchorConstraints(uiHostingViewController.view)
		}
    #if os(iOS)
		uiHostingViewController.didMove(toParent: self)
    #endif
    updateContentSize()

		// contentViewController.view.sizeToFit()
		// preferredContentSize = contentViewController.view.bounds.size

		// view.layer.borderColor = UIColor.purple.cgColor
		// view.layer.borderWidth = 1

		// contentHostingViewController.preferredContentSize.height = UIScreen.main.bounds.height/3
		// self.preferredContentSize.height = UIScreen.main.bounds.height/3

		// contentHostingViewController.view.layer.borderColor = UIColor.green.cgColor
		// contentHostingViewController.view.layer.borderWidth = 2
	}

	func updateContentSize(to newHeight: CGFloat? = nil) {
		return
		// view.sizeToFit()
    #if os(iOS)
            uiHostingViewController.view.sizeToFit()
#endif

		// contentViewController.preferredContentSize = contentViewController.view.bounds.size
		// preferredContentSize = view.bounds.size
		// print (preferredContentSize)

		// view.setNeedsLayout()
		// let fittingSize = CGSize(width: UIView.layoutFittingExpandedSize.width, height: UIView.layoutFittingExpandedSize.height)

		// let fittingSize = CGSize(width: UIView.layoutFittingExpandedSize.width, height: UIView.layoutFittingExpandedSize.height)

		// contentHostingViewController.preferredContentSize = contentHostingViewController.sizeThatFits(in: fittingSize)
		// preferredContentSize = contentHostingViewController.sizeThatFits(in: fittingSize)

		// preferredContentSize = view.sizeThatFits(in: fittingSize)
		// contentHostingViewController.preferredContentSize = contentHostingViewController.view.sizeThatFits(in: fittingSize)

		// self.view.bounds.size = fittingSize

		uiHostingViewController.preferredContentSize = uiHostingViewController.view.frame.size
		self.preferredContentSize = uiHostingViewController.view.frame.size


	}
}


