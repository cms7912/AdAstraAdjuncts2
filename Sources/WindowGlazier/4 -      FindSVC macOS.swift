//
//  File.swift
//  
//
//  Created by cms on 2/6/22.
//

import Foundation


#if os(macOS)
import AppKit

public extension HostWindowGlazier {

	func updateSVCStatus() {
		if splitViewController == nil {
			findSplitViewController()
		}
		if keepSVCClosed { keepClosed() }
	}
	@discardableResult
	func findSplitViewController() -> NSSplitViewController? {
		guard splitViewController == nil else { return splitViewController }
		// guard let window = window else { return nil }

		print("HostWindowGlazier searching for splitViewController in \(self.windowType)")
		splitViewController = Self.SearchSubviewsForSVC(windowReference?.contentView?.subviews)
		if splitViewController == nil {
			print("HostWindowGlazier never found splitViewController")
		} else {
			print("HostWindowGlazier found splitViewController")
		}
		return splitViewController
	}

	static func SearchSubviewsForSVC(_ subviews: [NSView]?) -> NSSplitViewController? {
		guard let subviews: [NSView] = subviews else { return nil }
		// print ("childControllers: \(childControllers.count)")
		for subview in subviews {
			if let sv = subview as? NSSplitView {
				print("Found splitView")
				if let svc = sv.delegate as? NSSplitViewController {
					print("Found splitViewController")
					return svc
				} else {
					print("but missing splitViewController, will continue")
				}
			} else {
				// print("not svc")
			}

			if let foundResult = SearchSubviewsForSVC(subview.subviews) {
				return foundResult
			}
		}
		return nil
	}

	func observeSVCWillResizeSubviews(_ callBlock: @escaping (_: Notification) -> Void  ) -> NSObjectProtocol? {
		guard let svc = splitViewController else { return nil }
		let splitView = svc.splitView
		return NotificationCenter.default.addObserver(
			forName: NSSplitView.willResizeSubviewsNotification,
			object: splitView,
			queue: .main ) { (n) in
				callBlock(n)
			}
	}
	func observeSVCDidResizeSubviews(_ callBlock: @escaping (_: Notification) -> Void  ) -> NSObjectProtocol? {
		guard let svc = splitViewController else { return nil }
		let splitView = svc.splitView
		return NotificationCenter.default.addObserver(
			forName: NSSplitView.willResizeSubviewsNotification,
			object: splitView,
			queue: .main ) { (n) in
				callBlock(n)
			}
	}
}


public extension NSSplitViewController {
	enum DisplayMode: Int {
		case oneBesideSecondary
		case automatic
		case secondaryOnly
	}
	enum Column: Int {
		case primary
		case supplementary
		case secondary
		case compact
	}
	
	var displayMode: DisplayMode {
		if isCollapsed { return .secondaryOnly }
		return .oneBesideSecondary
	}
	var preferredDisplayMode: DisplayMode {
		get { displayMode }
		set { }
	} 
	
	func showSidebar(){
		// if isCollapsed {
		// 	self.toggleSidebar()
		// }
		self.splitViewItems.first?.isCollapsed = false
	}
	func hideSidebar(){
		// if !isCollapsed {
		// 	self.toggleSidebar()
		// }
		self.splitViewItems.first?.isCollapsed = true
	}
	
	func show(_ value: Any){ showSidebar() }
	func hide(_ value: Any){ hideSidebar() }
	func toggleSidebar(){
		self.toggleSidebar(nil)
	}
	
	var isCollapsed: Bool {
		// for subview in self.splitView.subviews {
		// 	if self.splitView.isSubviewCollapsed(subview) {
		// 		print("found collapsed")
		// 	} else {
		// 		print("found uncollapsed")
		// 	}
		// }
		
		// return self.splitView.isSubviewCollapsed(self.splitView.subviews.first ?? NSView())
		return splitViewItems.first?.isCollapsed ?? true
	}
	var isExpanded: Bool { !isCollapsed }
	var presentsWithGesture: Bool {
		get { false }
		set{ }
	}
	
}



#endif


