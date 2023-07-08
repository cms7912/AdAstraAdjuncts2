//
//  File.swift
//
//
//  Created by cms on 12/6/21.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit

// import AdAstraBridgingByMask
#endif

#if os(iOS)
// public typealias UINSApplication = UIApplication
// public typealias UINSAlertController = UIAlertController
#elseif os(macOS)
// public typealias UINSApplication = NSApplication
#endif

#if os(macOS)
import AppKit
import PDFKit

// public typealias UINSAlertController = NSAlert



public protocol NSDocumentPickerDelegate { }

@objc
extension NSView { }



// public typealias UINSViewController = NSViewController
// open class NSViewControllerBridgeOne: NSViewController {
// 	func viewWillAppear(_ animated: Bool){
// 		self.viewWillAppear()
// 	}
// }
// open class NSViewControllerBridge: NSViewControllerBridgeOne {
extension NSViewController {
  // func viewWillAppear(_ animated: Bool){
  // 	super.viewWillAppear()
  // }

  // public func didMove(toParent parentVC: NSViewController){
  // there is no AppKit equivilant for didMove ViewController
  // }
}

// open class NSHostingControllerBridge<Content: View>: NSHostingController<Content> {
//
// 	public func viewWillAppear(_ animated: Bool){
// 		// self.viewWillAppear()
// 	}
//
// 	@objc
// 	public func didMove(toParent parentVC: NSViewController){
// 		self.didMove(toParent: parentVC)
// 	}
// }

// public extension NSSplitViewController {
//   enum DisplayMode: Int {
//     case oneBesideSecondary
//     case automatic
//     case secondaryOnly
//   }
//   enum Column: Int {
//     case primary
//     case supplementary
//     case secondary
//     case compact
//   }
//
//   var displayMode: DisplayMode {
//     return .oneBesideSecondary
//   }
//   var preferredDisplayMode: DisplayMode {
//     get { return .automatic }
//     set { }
//   }
//   func show(_ value: Any){ }
//   func hide(_ value: Any){ }
//   var isCollapsed: Bool { false }
//   var presentsWithGesture: Bool {
//     get { false }
//     set{ }
//   }
//   // TODO: need to set up these functions. (or go back to calling code and add code for macOS)
//   // these are implimented by UISplitViewController but not by NSSplitViewController
// }

public extension NSScrollView {
  // var clipToBounds: Bool {
  // 	get { self.wantsLayer = true; return self.layer?.masksToBounds ?? true }
  // 	set { self.wantsLayer = true; self.layer?.masksToBounds = newValue }
  // }
}

public extension NSColor {
  convenience init(dynamicProvider: @escaping (NSAppearance) -> NSColor) {
    self.init(name: nil, dynamicProvider: dynamicProvider)
  }
}

public extension NSColor {
  static var label = NSColor.labelColor
  static var secondaryLabel = NSColor.secondaryLabelColor
  static var tertiaryLabel = NSColor.tertiaryLabelColor
  static var quarternaryLabel = NSColor.quaternaryLabelColor
  static var placeholderText = NSColor.placeholderTextColor
  static var link = NSColor.linkColor

  static var aaSystemFill = NSColor.windowBackgroundColor
  // static var secondarySystemFill = NSColor.secondarySystemFill
  // static var tertiarySystemFill = NSColor.tertiarySystemFill
  // static var quarternarySystemFill =

  static var aaSystemBackground = NSColor.windowBackgroundColor
  static var aaSecondarySystemBackground = NSColor.underPageBackgroundColor
  // static var tertiarySystemBackground = NSColor.tertiarySystemBackground

  static var aaSystemGroupedBackground = NSColor.underPageBackgroundColor
  // static var secondarySystemGroupedBackground = NSColor.underPageBackgroundColor.withAlphaComponent(0.50)
  // static var tertiarySystemGroupedBackground = NSColor.tertiarySystemGroupedBackground
}

public extension NSTextView {
  var text: String {
    get {
      return string
    }
    set {
      string = newValue
    }
  }

  // var contentSize: CGSize {
  // 	assert(false)
  // 		return .zero
  // }
  var zoomScale: CGFloat { 1.0 }
  // UITextView inherits from UIScrollView and so gets 'zoomScale' property. NSTextView does not inherit from NSScrollView, so does not get the equivilant 'magnification' property
}

public extension NSFont {
  // TODO: Implement This
  static func italicSystemFont(ofSize fontSize: CGFloat) -> NSFont {
    return NSFont.systemFont(ofSize: fontSize)
  }
  // convenience init?(textStyle: NSFont.TextStyle, options: [NSFont.TextStyleOptionKey:Any]) {
  // 	let f =	Self.preferredFont(forTextStyle: textStyle, options: options)
  // 	self.init(descriptor: f.fontDescriptor , size: f.pointSize)
  // }
}


public extension NSAlert {
  convenience init(title: String, message: String, preferredStyle _: NSAlert.UIAlertStyle) {
    NSAlert.buttonActionHandlers.removeAll()
    self.init()
    messageText = title
    informativeText = message
    alertStyle = .warning
    addButton(withTitle: "Exit")
  }

  // func addAction(title: String, style: )
}


public enum PDFThumbnailLayoutMode: Int {
  case horizontal
  case vertical
}

public extension PDFThumbnailView {
  var layoutMode: PDFThumbnailLayoutMode {
    get { return .vertical }
    set { }
    // not sure where these should go in AppKit's PDFThumbnailView
    // only AppKit's PDFThumbnailView has "maximumNumberOfColumns"
    // ? maybe it lays as usual, always. Then if horizontal/vertical only provides space for one column/row that is what it portrays
  }
}


public extension NSValue {
  var cgPointValue: NSPoint { self.pointValue }
  convenience init(cgPoint: NSPoint) {
    self.init(point: cgPoint)
  }
}



// #if os(iOS)

public extension NSAlert {
  enum UIAlertStyle {
    // 	// case actionSheet
    case alert
    // 	// case warning = 0
    // 	// case informational = 1
    // 	// case critical = 2
    //
  }

  // enum ButtonStyle {
  // 	case cancel
  // 	case destructive
  // 	case `default`
  // }

  // 	func addAction(buttonTitle: String, style:  ButtonStyle, handler: ()->Void  ) {
  // #if os(iOS)
  // 		self.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in handler() }))
  //
  // #endif
  //
  // #if os(macOS)
  // 		self.addButton(withTitle: buttonTitle)
  // 		ToDo(.highImportance, "Add calling the appropriate handler")
  // 		// https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift/29433631
  // #endif
  // 	}

  func addAction(_ action: NSAppAlertAction) {
    addButton(withTitle: action.title)
    alertStyle = { () -> NSAlert.Style in
      switch action.style {
        case .default:
          print("default")
          return NSAlert.Style.informational
        case .cancel:
          print("cancel")
          return NSAlert.Style.informational
        case .destructive:
          print("destruct")
          return NSAlert.Style.warning
      }
    }()
    Self.buttonActionHandlers.append(action.handler)
  }

  static var buttonActionHandlers: [(Any?) -> Void] = []
  // this is a hack that stores each .addButton's handler and then when button pressed calls them as first/second/third buttons. This hack assumes only one alert dialog can appear at a time
}

public class NSAppAlertAction {
  public enum Style {
    case `default`
    case cancel
    case destructive
  }

  var title: String
  var style: NSAppAlertAction.Style
  var handler: (Any?) -> Void

  public init(title: String, style: NSAppAlertAction.Style, handler: @escaping (Any?) -> Void) {
    self.title = title
    self.style = style
    self.handler = handler
  }
}



// MARK: - - SwiftUI

import SwiftUI

public extension ToolbarItemPlacement {
  // static let navigationBarLeading = navigation
  // static let navigationBarTrailing = navigation
}


// https://useyourloaf.com/blog/swiftui-custom-environment-values/
public enum AA_UserInterfaceSizeClass {
  case regular
  case compact // never active but needed as option for comparisons that use it
}

private struct HorizontalSizeClassOnMacKey: EnvironmentKey {
  static let defaultValue: UserInterfaceSizeClass? = UserInterfaceSizeClass.regular
}

#if Disabled
public extension EnvironmentValues {
  var horizontalSizeClass: UserInterfaceSizeClass? {
    get { self[HorizontalSizeClassOnMacKey.self] }
    set { self[HorizontalSizeClassOnMacKey.self] = newValue }
  }
}
#endif

private struct VerticalSizeClassOnMacKey: EnvironmentKey {
  static let defaultValue: UserInterfaceSizeClass? = UserInterfaceSizeClass.regular
}

public extension EnvironmentValues {
  var verticalSizeClass: UserInterfaceSizeClass? {
    get { self[VerticalSizeClassOnMacKey.self] }
    set { self[VerticalSizeClassOnMacKey.self] = newValue }
  }
}

public extension View {
  // @available(macOS, obsoleted: 12.0)
  // @available(iOS, obsoleted: 15.0)
  // static func _printChanges(){
  // }
}

public extension Image {
  init(uiImage image: NSImage) {
    self.init(nsImage: image)
  }
}


#if Disabled

public protocol UINSViewRepresentable: NSViewRepresentable {
  func makeUIView(context: Context) -> Self.NSViewType
  func updateUIView(_: Self.NSViewType, context: Context)
}

public extension UINSViewRepresentable {
  func makeNSView(context: Context) -> Self.NSViewType {
    makeUIView(context: context)
  }
  func updateNSView(_ uiView: Self.NSViewType, context: Context) {
    updateUIView(uiView, context: context)
  }
}

#endif

// public protocol UINSViewControllerRepresentable: NSViewControllerRepresentable {
// 	func makeUIViewController(context: Context) -> Self.NSViewControllerType
// 	func updateUIViewController(_: Self.NSViewControllerType, context: Context)
// }
// public extension UINSViewControllerRepresentable {
// 	func makeNSViewController(context: Context) -> Self.NSViewControllerType {
// 		self.makeUIViewController(context: context)
// 	}
// 	func updateNSViewController(_ uiView: Self.NSViewControllerType, context: Context) {
// 		self.updateUIViewController(uiView, context: context)
// 	}
// }


public extension NSCollectionView {
  func dequeueReusableCell(withReuseIdentifier id: String, for path: IndexPath) -> NSCollectionViewItem {
    makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), for: path)
  }
}

public extension IndexPath {
  var row: Int { item }
}

public extension NSCollectionViewDataSource{
  func collectionView(_ collectionView: NSCollectionView, cellForItemAt indexPath: IndexPath) -> NSCollectionViewItem {
    self.collectionView(collectionView, itemForRepresentedObjectAt: indexPath)
  }
}
#endif // if os(macOS)
