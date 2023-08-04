//
//  File.swift
//  
//
//  Created by cms on 2/6/22.
//

import Foundation
import SwiftUI
import CoreData

// @EnvironmentObject var hostWindowGlazier: HostWindowGlazier
public class HostWindowGlazier: ObservableObject, Equatable {
	public static func == (lhs: HostWindowGlazier, rhs: HostWindowGlazier) -> Bool {
		lhs.glazierID == rhs.glazierID
	}

	public static func Init(urlScheme: String, windowTypeStrings: [String]){
		Self.AppProvidedURLScheme = urlScheme
		Self.AppProvidedWindowTypeStrings = windowTypeStrings
	}
	static var AppProvidedURLScheme: String = ""
	static var AppProvidedWindowTypeStrings: [String] = [String]()

	static var ExistingGlaziers: [HostWindowGlazier] = [HostWindowGlazier]()

	static func VerifyWindowType(_ name: String?) -> Bool {
		guard let name = name else { return false }
		return AppProvidedWindowTypeStrings.contains(name)
	}

	init(as type: String, keepSVCClosed: Bool = false, updateSVCDisplayMode: Bool = false){
		self.windowType = type
		self.keepSVCClosed = keepSVCClosed
		self.observeSVCDisplayModeChanges = updateSVCDisplayMode
		if updateSVCDisplayMode { startObservingSVCDisplayMode() }

		if !Self.ExistingGlaziers.contains(self) {
			Self.ExistingGlaziers.append(self)
		}
	}
	var glazierID: UUID = UUID()

	func cleanUp(){
		HostWindowGlazier.ExistingGlaziers.removeAll{
			$0 == self
		}
		self.externalEventRequest = nil
	}

	// @Published
	public private(set) var isKeyWindow: Bool = false {
		willSet {
			print("isKeyWindow: \(isKeyWindow)")
		}
	}

	@Published
	public var splitViewController: NSSplitViewController? {
		willSet{
			print("splitViewController: \(newValue != nil)")
		}
		didSet {
			if keepSVCClosed { self.keepClosed() }
		}
	}
	@Published var svcDisplayMode: NSSplitViewController.DisplayMode? {
		// warning the svcDisplayMode publishing will duplicate if app is also observing SVC changes
		willSet {
			print("svcDisplayMode: \(svcDisplayMode)")
		}
	}
	func refreshSVCDisplayModeValue(){
		guard observeSVCDisplayModeChanges else { return }
		if svcDisplayMode != splitViewController?.displayMode {
			svcDisplayMode = splitViewController?.displayMode
		}
	}
	var observeSVCDisplayModeChanges: Bool {
		didSet {
			if observeSVCDisplayModeChanges && !oldValue {
				startObservingSVCDisplayMode()
			}
		}
	}
	func startObservingSVCDisplayMode(){
		refreshSVCDisplayModeValue()
		svcDidResizeSubviewsObserver = observeSVCDidResizeSubviews{ _ in
			self.refreshSVCDisplayModeValue()
		}
	}

	let keepSVCClosed: Bool
	func keepClosed() {
		guard keepSVCClosed else { return }
		splitViewController?.splitViewItems.first?.isCollapsed = true
		splitViewController?.splitViewItems.first?.automaticMaximumThickness = 0
		splitViewController?.splitViewItems.first?.automaticMaximumThickness = 0
		splitViewController?.splitViewItems.first?.preferredThicknessFraction = 0
		splitViewController?.splitViewItems.first?.isSpringLoaded = false
		// if these periodically get overwritten, then try 'observeSVCWillResizeSubviews()' and set them again
	}

	var becomeKeyObserver: NSObjectProtocol?
	var resignKeyObserver: NSObjectProtocol?
	var willCloseObserver: NSObjectProtocol?
	var svcWillResizeSubviewsObserver: NSObjectProtocol?
	var svcDidResizeSubviewsObserver: NSObjectProtocol?

	public weak var windowReference: NSWindow? {
		willSet {
			self.objectWillChange.send()
			guard let newWindow = newValue else {
				assert(false) // when would window ever be changed to nil
				// if now nil then turn off glaziers
				self.isKeyWindow = false
				self.becomeKeyObserver = nil
				self.resignKeyObserver = nil
				return
			}

			if !Self.ExistingGlaziers.contains(self) {
				Self.ExistingGlaziers.append(self)
			}

			self.isKeyWindow = newWindow.isKeyWindow

			self.becomeKeyObserver =
			NotificationCenter.default.addObserver(
				forName: NSWindow.didBecomeKeyNotification,
				object: newWindow,
				queue: .main
			) { (n) in
				self.isKeyWindow = true
			}

			self.resignKeyObserver =
			NotificationCenter.default.addObserver(
				forName: NSWindow.didResignKeyNotification,
				object: newWindow,
				queue: .main
			) { (n) in
				self.isKeyWindow = false
			}

			self.willCloseObserver =
			NotificationCenter.default.addObserver(
				forName: NSWindow.willCloseNotification,
				object: newWindow,
				queue: .main
			) { (n) in
				self.cleanUp()
			}

		}
	}
	// https://lostmoa.com/blog/ReadingTheCurrentWindowInANewSwiftUILifecycleApp/

	public var windowBinding: Binding<NSWindow?> { Binding<NSWindow?>(
		get: { [weak self] in self?.windowReference },
		// set: { [weak self] in self?.windowReference = $0 } )
		set: { [weak self] in self?.windowReference = $0 } ) }



	@Published
	public var externalEventRequest: GlazierExternalEventRequest? {
		willSet {
			// assert(newValue != nil)
			print("old externalEventRequest: \(externalEventRequest?.eventURL.absoluteString ?? "")")
			print("new externalEventRequest: \(newValue?.eventURL.absoluteString ?? "")")
		}
		didSet {
			guard oldValue != externalEventRequest else { return }
			appWindowIDAsURI = appWindowIDAsURICalculated
		}
	}
	public var externalEventQueries: [String:String?] {
		externalEventRequest?.queryDictionary ?? [String:String?]()
	}
	var windowType: String
	public var appWindowID: String? {
		externalEventQueries[GlazierExternalEventRequest.AppWindowIDName] ?? nil
	}
	/// convenience variable for appWindowID stored as Core Data's objectID.uriRepresentation()
	public var appWindowIDAsURICalculated: URL?{
		if let uriString: String = appWindowID,
			 let uri = URL(string: uriString) {
			return uri
		}
		return nil

	}
	@Published
	public var appWindowIDAsURI: URL?

}

public extension NSWindow {

	var glazierCalculated: HostWindowGlazier? {
		HostWindowGlazier.ExistingGlaziers.first{ $0.windowReference == self }
	}

}

