//
//  File.swift
//
//
//  Created by cms on 12/6/21.
//

import Foundation

#if os(macOS)
@_exported import AppKit
//import AdAstraBridgingNSExtensions

public typealias UINSView = NSView
public typealias UINSColor = NSColor
public typealias UINSFont = NSFont
public typealias UINSImage = NSImage
public typealias UINSImageView = NSImageView
public typealias UINSLabel = NSTextView
public typealias UINSTextField = NSTextField
public typealias UINSTextFieldDelegate = NSTextFieldDelegate
public typealias UINSPasteboard = NSPasteboard
public typealias UINSBezierPath = NSBezierPath
public typealias UINSScrollView = NSScrollView
public typealias UINSButton = NSButton
public typealias UINSStackView = NSStackView
// public typealias UINSBarButtonItem =

public typealias UINSScreen = NSScreen
public typealias UINSWindow = NSWindow
public typealias UINSScene = NSObject // no equivalent
public typealias UINSAppearance = NSAppearance
public typealias UINSEdgeInsets = NSEdgeInsets
public typealias UINSTextViewDelegate = NSTextViewDelegate
public typealias UINSResponder = NSResponder
public typealias UINSSplitViewController = NSSplitViewController
public typealias UINSSplitViewDelegate = NSSplitViewDelegate

public typealias UINSTapGestureRecognizer = NSClickGestureRecognizer
public typealias UINSLongPressGestureRecognizer = NSPressGestureRecognizer
public typealias UINSPanGestureRecognizer = NSPanGestureRecognizer


public typealias UINSUserInterfaceLayoutOrientation = NSUserInterfaceLayoutOrientation
public typealias UINSLayoutPriority = NSLayoutConstraint.Priority
public typealias UINSLayoutGuide = NSLayoutGuide

public typealias UINSAlertController = NSAlert
//public typealias UINSAlertAction = NSAppAlertAction // bridge below for NS UIAlertAction

public typealias UINSApplication = NSApplication
public typealias UINSApplicationDelegate = NSApplicationDelegate
// public typealias UINSViewController = NSViewController

//public typealias UINSDocumentPickerDelegate = NSDocumentPickerDelegate

public typealias UINSCollectionView = NSCollectionView
public typealias UINSCollectionViewDelegate = NSCollectionViewDelegate
public typealias UINSCollectionViewDataSource = NSCollectionViewDataSource
public typealias UINSCollectionViewFlowLayout = NSCollectionViewFlowLayout
public typealias UINSCollectionReusableView = NSCollectionViewItem
public typealias UINSCollectionViewCell = NSCollectionViewItem


public typealias UINSEvent = NSEvent


public extension NSApplication {
  func canOpenURL(_: URL) -> Bool { true }
  func open(_ url: URL, options _: NSDictionary) {
    NSWorkspace.shared.open(url)
  }

  static let didReceiveMemoryWarningNotification = Notification.Name("didReceiveMemoryWarningNotification")

  func sendAction(_ action: Selector,
                  to target: Any?,
                  from sender: Any?,
                  for _: NSEvent?) -> Bool
  {
    sendAction(action, to: target, from: sender)
  }
}

public extension NSApplicationDelegate { }

public extension NSScreen {
  var bounds: NSRect { frame }
 static var aaMain: NSScreen? { NSScreen.main }
}

open class UINSViewController: NSViewController {
  func viewDidAppear(_: Bool) {
    viewDidAppear()
  }
  open func viewDidLayoutSubviews() {
    self.viewDidLayout()
  }

}

extension NSView {
  @objc
  open func hitTest(_ point: CGPoint, with _: UINSEvent? = nil) -> UINSView? {
    hitTest(point)
  }

  // public var layer: CALayer {
  //   get {
  //     return self.layer ?? self.makeBackingLayer()
  //   }
  //   set {
  //     self.layer = newValue
  //   }
  // }

  open func willMove(toSuperview superview: NSView) {
    viewWillMove(toSuperview: superview)
  }

  @objc
  open func didMoveToSuperview() {
    viewDidMoveToSuperview()
  }

  public func uinsSizeToFit() {
    frame.size = fittingSize
  }

  open var uinsFittingSize: CGSize { self.fittingSize }

  public func isDarkMode() -> Bool {
    // return self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    NSAppearance.isDarkMode
  }

  @objc
  open func layoutSubviews() {
    layout()
  }

  public func setNeedsLayout() {
    needsLayout = true
  }

  @objc
  open func layoutIfNeeded() {
    if needsLayout { layoutSubviews() }
  }

  public var backgroundColor: NSColor? {
    get { self.wantsLayer = true; return NSColor(cgColor: self.layer?.backgroundColor ?? CGColor.clear) }
    set { self.wantsLayer = true; self.layer?.backgroundColor = newValue?.cgColor }
  }

  // open var aaClipToBounds: Bool {
  //   get { self.wantsLayer = true; return self.layer!.masksToBounds }
  //   set { self.wantsLayer = true; self.layer?.masksToBounds = newValue }
  // }
  // open var aaClipsToBounds: Bool {
  //   get { self.wantsLayer = true; return self.layer!.masksToBounds }
  //   set { self.wantsLayer = true; self.layer?.masksToBounds = newValue }
  // }

  public var uinsClipToBounds: Bool {
    get { self.wantsLayer = true; return self.layer!.masksToBounds }
    set { self.wantsLayer = true; self.layer?.masksToBounds = newValue }
  }

  public var uinsClipsToBounds: Bool {
    get { wantsLayer = true; return layer!.masksToBounds }
    set { wantsLayer = true; layer?.masksToBounds = newValue }
  }

  public var uinsLayer: CALayer? { wantsLayer = true; return layer }
  
  open func traitCollectionDidChange(_ previousTraitCollection: Any?) {
    self.updateLayer()
  }
  
  
  public var alpha: CGFloat {
    get {
      self.alphaValue
    } set {
      self.alphaValue = newValue
    }
  }
  
  public class func animate(withDuration: TimeInterval, closure: () -> Void) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      // self.layoutSubtreeIfNeeded(self)
      closure()
    }, completionHandler: nil)
  }
  public class func animate(withDuration: TimeInterval,
                            delay: Double,
                            usingSpringWithDamping: Double,
                            initialSpringVelocity: Double
                            , closure: () -> Void) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.25
      // self.layoutSubtreeIfNeeded(self)
      closure()
    }, completionHandler: nil)
  }

  public var transform: CGAffineTransform {
    get {
      self.layer!.affineTransform()
    }
    set {
      self.layer?.setAffineTransform(newValue)
    }
  }
  
  
  #if Disabled
  public enum ContentMode {
    case scaleAspectFit
  }
  var contentMode: ContentMode? {
    get {
      switch self.imageScaling {
        case .scaleProportionallyUpOrDown:
          return .scaleAspectFit
        default:
          assertionFailure()
          return .scaleAspectFit
      }
    }
    set {
      switch newValue {
        case .scaleAspectFit:
          self.imageScaling = .scaleProportionallyUpOrDown
        default:
          assertionFailure()
          self.imageScaling = .scaleProportionallyUpOrDown
      }
    }
  }
  #endif

  
}

public extension NSAppearance {
  enum UserInterfaceStyle {
    case light
    case dark
  }

  static var userInterfaceStyle: UserInterfaceStyle {
    let appearance = NSAppearance.currentDrawing()

    switch appearance.name {
      case .aqua:
        return .light
      case .darkAqua:
        return .dark
      default:
        return .light
    }
  }

  var userInterfaceStyle: UserInterfaceStyle { Self.userInterfaceStyle }

  static var isLightMode: Bool { userInterfaceStyle == .light }
  static var isDarkMode: Bool { userInterfaceStyle == .dark }
}

extension NSColor {
  public static var isLightMode: Bool {
    NSAppearance.isLightMode
  }

  public static var isDarkMode: Bool {
    NSAppearance.isDarkMode
  }
  
}

extension NSFont {
  open var lineHeight: CGFloat {
    ascender +
      (descender * -1) +
      leading
    // https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/FontHandling/FontHandling.html
  }
}

public extension UINSImageView {
  var tintColor: NSColor? {
    get {
      self.contentTintColor
    }
    set {
      self.contentTintColor = newValue
    }
  }
}

open class UINSTextView: NSTextView {
  override public init(frame: NSRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
  }





  override public init(frame frameRect: CGRect) {
    // assertionFailure("UINS error - use init(frame: textContainer: ) instead")
    print("⚠️ ⚠️ ⚠️ UINS error - use init(frame: textContainer: ) instead")
    super.init(frame: frameRect)
  }



  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }



  open var uinsTextContainer: NSTextContainer? { super.textContainer }

  open var uinsAllowsUndo: Bool { get { super.allowsUndo } set { super.allowsUndo = newValue } }

  public var uinsAttributedText: NSAttributedString? {
    get {
      attributedString()
    }
    set {
      textStorage?.setAttributedString(newValue ?? NSAttributedString())
    }
  }

  public var nsAttributedString: NSAttributedString {
    get {
      attributedString()
    }
    set {
      textStorage?.setAttributedString(newValue)
    }
  }


  public var isFocused: Bool {
    window?.firstResponder == self
  }
  
  public var selectedTextRange: NSRange? {
    self.selectedRange()
  }

  // public var attributedString: AttributedString? {
  //   get {
  //     let nsString = self.textStorage?.attributedSubstring(from: self.textStorage?.fullRange)
  //
  //     // AttributedString(nsString, including: )
  //     // don't want to get the attributedString from NSAttributedString here because 'including' AttributesScope is unknown.
  //   }
  //   set {
  //     textStorage?.setAttributedString(NSAttributedString(newValue ?? AttributedString() ))
  //   }
  // }?
}

public extension UINSTextView{
  static var uinsTextDidChangeNotification: NSNotification.Name { Self.didChangeNotification }
  
  var uinsTextStorage: NSTextStorage? {
    return textStorage
  }
  
  func uinsShouldChangeText(in range: NSRange, replacementText: String?) -> Bool {
    shouldChangeText(in: range, replacementString: replacementText)
  }
}
public extension NSTextView{
  var textAlignment: NSTextAlignment {
    get {
      self.alignment
    }
    set {
      self.alignment = newValue
    }
  }
  
  // var contentMode: ContentMode {
  //   get {
  //     assertionFailure()
  //     return .scaleAspectFit
  //   }
  //   set {
  //     
  //   }
  // }
}

public extension NSTextView {
  var text: String {
    get {
      return self.string
    }
    set {
      self.string = newValue
    }
  }
}


public extension NSImage {
  convenience init(systemName name: String) {
    self.init(systemName: name)
  }
  
  // convenience init(systemName name: String,
  //                  withConfiguration config: NSImage.SymbolConfiguration) {
  //   self.init(systemName: name)
  //   if let newSelf = self.withSymbolConfiguration(config) {
  //     
  //   }
  // }
  
}



public extension NSImage {
  func jpegData(compressionQuality _: Int) -> Data {
    if let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil),
       case let bitmapRep = NSBitmapImageRep(cgImage: cgImage),
       let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])
    {
      return jpegData
    }

    print("unexpectedly unable to create jpeg, will return empty Data()")
    return Data()
    // https://stackoverflow.com/questions/35003156/how-can-i-write-an-nsimage-to-a-jpeg-file-in-swift
  }

  func pngData() -> Data?{
    if let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil),
       case let bitmapRep = NSBitmapImageRep(cgImage: cgImage),
       let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
    {
      return jpegData
    }
    print("unexpectedly unable to create png, will return empty Data()")
    return Data()
    // https://stackoverflow.com/questions/35003156/how-can-i-write-an-nsimage-to-a-jpeg-file-in-swift
  }

  static func cgImage(cgImage: CGImage) -> NSImage {
    NSImage(cgImage: cgImage, size: .zero)
  }

  var cgImage: CGImage? {
    self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    // https://stackoverflow.com/questions/24595908/swift-nsimage-to-cgimage
  }
}

extension NSCollectionViewDiffableDataSource {
  // public func collectionView(_ collectionView: UINSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UINSCollectionReusableView {
  //   self.collectionView(collectionView,
  //                       viewForSupplementaryElementOfKind: kind,
  //                       at: indexPath)
  // }
  
}


#endif


// MARK: - - SwiftUI

#if os(macOS) && canImport(SwiftUI)
import SwiftUI

public typealias UINSHostingController = NSHostingController

// public typealias UINSViewRepresentable = NSViewRepresentable
// public typealias UINSViewControllerRepresentable = NSViewControllerRepresentable

// public typealias UINSViewControllerRepresentable = NSViewControllerRepresentable
// public typealias UINSViewControllerRepresentableContext = NSViewControllerRepresentableContext
// instead, using extended protocol


#endif



public class UINSActivityIndicatorView: UINSView {
  public enum StyleSize {
    case large
    case medium
  }

  public var style: StyleSize

  public init(style: StyleSize) {
    self.style = style
    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  #if os(iOS)

  #endif

  #if os(iOS)



  lazy var spinner: UINSActivityIndicatorView = UINSActivityIndicatorView(style: style)
  #if os(macOS)
  public var isOpaque: Bool {
    get { spinner.isOpaque }
    set { spinner.isOpaque = newValue }
  }

  public var accessibilityIdentifier: String {
    get { spinner.accessibilityIdentifier }
    set { spinner.setAccessibilityIdentifier = newValue }
  }

  public var isAccessibilityElement: Bool {
    get { spinner.isAccessibilityElement }
    set { spinner.setAccessibilityElement = newValue; setAccessibilityElement = newValue }
  }
  #endif

  public var color: UINSColor {
    get { spinner.color }
    set { spinner.color = newValue }
  }

  public func startAnimating() {
    spinner.startAnimating()
  }

  public func stopAnimating() {
    spinner.stopAnimating()
  }

  public var isAnimating: Bool { spinner.isAnimating }


  #elseif os(macOS)
  lazy var spinner: NSProgressIndicator = {
    let spinner = NSProgressIndicator(frame: .zero) // will later adjust frame via constraints
    spinner.style = .spinning
    spinner.controlSize = self.style == .large ? .large : .small
    return spinner
  }()

  override public var isOpaque: Bool {
    get { spinner.isOpaque }
    set { spinner.window?.isOpaque = newValue }
  }

  public var accessibilityIdentifier: String {
    get { spinner.accessibilityIdentifier() }
    set { spinner.setAccessibilityIdentifier(newValue) }
  }

  public var isAccessibilityElement: Bool {
    get { spinner.isAccessibilityElement() }
    set { spinner.setAccessibilityElement(newValue); setAccessibilityElement(newValue) }
  }

  public var color: UINSColor {
    get { UINSColor.gray }
    set { }
  }

  public func startAnimating() {
    isAnimating = true
    spinner.startAnimation(nil)
  }

  public func stopAnimating() {
    isAnimating = false
    spinner.stopAnimation(nil)
  }

  public var isAnimating: Bool = false



  #endif
}

#if os(macOS)
public extension NSBezierPath {
  convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
    self.init(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
  }

  var cgPath: CGPath {
    let path = CGMutablePath()
    var points = [CGPoint](repeating: .zero, count: 3)

    for i in 0 ..< elementCount {
      let type = element(at: i, associatedPoints: &points)
      switch type {
        case .moveTo:
          path.move(to: points[0])
        case .lineTo:
          path.addLine(to: points[0])
        case .curveTo:
          path.addCurve(to: points[2], control1: points[0], control2: points[1])
        case .closePath:
          path.closeSubpath()
        @unknown default:
          continue
      }
    }

    return path
  }
  // https://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath
}

public extension NSGestureRecognizer {
  func addTarget(_ target: AnyObject?, action: Selector?) {
    self.target = target
    self.action = action
  }

  func removeTarget(_: AnyObject?, action _: Selector?) {
    target = nil
    action = nil
  }
}



import CoreData

public extension NSEntityDescription {
  var uinsAttributesByName: [String: NSAttributeDescription] {
    attributesByName
  }
}





#endif






