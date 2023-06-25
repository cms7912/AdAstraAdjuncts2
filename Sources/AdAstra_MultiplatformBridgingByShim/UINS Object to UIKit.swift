//
//  File.swift
//
//
//  Created by cms on 12/6/21.
//

import Foundation
#if os(iOS)
import UIKit


public typealias UINSView = UIView
public typealias UINSColor = UIColor
public typealias UINSFont = UIFont
public typealias UINSImage = UIImage
public typealias UINSImageView = UIImageView
public typealias UINSLabel = UILabel
// public typealias UINSTextView = UITextView
public typealias UINSTextField = UITextField
public typealias UINSPasteboard = UIPasteboard
public typealias UINSBezierPath = UIBezierPath
public typealias UINSScrollView = UIScrollView
public typealias UINSButton = UIButton
public typealias UINSStackView = UIStackView

public typealias UINSScreen = UIScreen
public typealias UINSWindow = UIWindow
public typealias UINSScene = UIScene // no equivalent
public typealias UINSAppearance = UIAppearance
public typealias UINSEdgeInsets = UIEdgeInsets
public typealias UINSTextViewDelegate = UITextViewDelegate
public typealias UINSResponder = UIResponder
public typealias UINSSplitViewController = UISplitViewController
public typealias UINSSplitViewDelegate = UISplitViewControllerDelegate

public typealias UINSTapGestureRecognizer = UITapGestureRecognizer
public typealias UINSLongPressGestureRecognizer = UILongPressGestureRecognizer
public typealias UINSPanGestureRecognizer = UIPanGestureRecognizer

public typealias UINSKeyCommand = UIKeyCommand

public typealias UINSUserInterfaceLayoutOrientation = NSLayoutConstraint.Axis
public typealias UINSLayoutPriority = UILayoutPriority

public typealias UINSAlertController = UIAlertController
public typealias UINSAlertAction = UIAlertAction

public typealias UINSApplication = UIApplication
public typealias UINSApplicationDelegate = UIApplicationDelegate
// public typealias UINSViewController = UIViewController

public typealias UINSDocumentPickerDelegate = UIDocumentPickerDelegate

public typealias UINSEvent = UIEvent

extension UINSApplicationDelegate { }

extension UIView {
  public var wantsLayer: Bool { get{ return true } set{ } }

  public var uinsClipToBounds: Bool {
    get { clipsToBounds }
    set { clipsToBounds = newValue }
  }

  public var uinsClipsToBounds: Bool {
    get { self.clipsToBounds }
    set { self.clipsToBounds = newValue }
  }

  open func uinsSizeToFit() {
    sizeToFit()
  }

  open var uinsFittingSize: CGSize {
    self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }

  open func viewDidMoveToSuperview() {
    didMoveToSuperview()
  }

  public var uinsLayer: CALayer? { layer }
}

public extension UIFont {
  // var uinsBoundingRectForFont: CGRect {
  //   CGRect(x: 0, y: 0,
  //          width: Self.monospacedSystemFont(
  //           ofSize: self.pointSize,
  //           weight: .regular).advancement , // this weight is an assumption
  //          height: lineHeight)
  //   let t = "a"
  // }
}

public extension UIColor {
  static var isLightMode: Bool {
    var light: Bool = true
    _ = UIColor{ light = ($0.userInterfaceStyle == .light); return .black }
    return light
  }

  static var isDarkMode: Bool { !isLightMode }
}

open class UINSViewController: UIViewController {
  open func viewDidAppear() {
    super.viewDidAppear(true)
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewDidAppear()
  }
}

open class UINSTextView: UITextView {
  // open var uinsLayer: CALayer? { self.layer }

  open var uinsTextContainer: NSTextContainer? { super.textContainer }
  // var wantsLayer: Bool { get { true } set { } }

  open var uinsAllowsUndo: Bool { get { true } set { _ = newValue } }

  public var uinsAttributedText: NSAttributedString? {
    get {
      attributedString()
    }
    set {
      textStorage.setAttributedString(newValue ?? NSAttributedString())
    }
  }

  public var nsAttributedString: NSAttributedString {
    get {
      attributedText
    }
    set {
      textStorage.setAttributedString(newValue)
    }
  }


  public func attributedString() -> NSAttributedString? {
    attributedText
  }
}

public extension UINSTextView{
  // typealias uinsTextDidChangeNotification = didChangeNotification
  static var uinsTextDidChangeNotification: NSNotification.Name { Self.textDidChangeNotification }

  var uinsTextStorage: NSTextStorage? {
    return textStorage
  }

  #if canImport(UIKit)
  func uinsShouldChangeText(in _: UITextRange, replacementText _: String) -> Bool {
    // self.shouldChangeText(in: range, replacementText: replacementText)
    return true
  }
  #endif
}

public extension UITextViewDelegate {
  func uinsTextViewDidEndEditing(_ textView: UITextView) {
    textViewDidEndEditing?(textView)
  }

  func uinsTextViewDidChange(_ textView: UITextView) {
    textViewDidChange?(textView)
  }
}

#endif


// MARK: - - SwiftUI

#if os(iOS) && canImport(SwiftUI)
import SwiftUI

public typealias UINSHostingController = UIHostingController
// public typealias UINSViewControllerRepresentable = UIViewControllerRepresentable
// public typealias UINSViewControllerRepresentableContext = UIViewControllerRepresentableContext
// public typealias UINSViewRepresentable = UIViewRepresentable

#endif




#if os(iOS)
import CoreData

public extension NSEntityDescription {
  var uinsAttributesByName: [String: NSAttributeDescription] {
    return attributesByName
  }
}


#endif

