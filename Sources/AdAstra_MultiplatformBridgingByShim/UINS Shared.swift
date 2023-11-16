//
//  File.swift
//
//
//  Created by cms on 10/8/22.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

// import AdAstraExtensions


public extension UINSLayoutGuide {
  func addSubviewWithAnchorConstraints(_ subview: UINSView,
                                       edges: [Edge] = Edge.allCases,
                                       centering: [Axis] = [],
                                       priority: Float = 1000)
  {
    let myGuide = self

    NSLayoutConstraint.activate( [
      NSLayoutConstraint(
        item: myGuide,
        attribute: .leading,
        relatedBy: .equal,
        toItem: subview,
        attribute: .leading,
        multiplier: 1,
        constant: 1
      ),
      NSLayoutConstraint(
        item: myGuide,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: subview,
        attribute: .trailing,
        multiplier: 1,
        constant: 1
      ),
      NSLayoutConstraint(
        item: myGuide,
        attribute: .top,
        relatedBy: .equal,
        toItem: subview,
        attribute: .top,
        multiplier: 1,
        constant: 1
      ),
      NSLayoutConstraint(
        item: myGuide,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: subview,
        attribute: .bottom,
        multiplier: 1,
        constant: 1
      ),
    ] )
    
  }
}
public extension UINSView {
  func addSubviewWithAnchorConstraints(_ subview: UINSView,
                                       edges: [Edge] = Edge.allCases,
                                       centering: [Axis] = [],
                                       priority: Float = 1000)
  {
    let view = self

    subview.willMove(toSuperview: view)
    view.addSubview(subview)
    subview.didMoveToSuperview()

    subview.translatesAutoresizingMaskIntoConstraints = false
    // subview always needs translatesAutoresizingMaskIntoConstraints turned off.
    // the parent view could need it, but can be set at site of call when needed

    if edges.contains(.leading) {
      let leadingAnchor = subview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      leadingAnchor.priority = UINSLayoutPriority(priority)
      leadingAnchor.isActive = true
    }

    if edges.contains(.trailing) {
      let trailingAnchor = subview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      trailingAnchor.priority = UINSLayoutPriority(priority)
      trailingAnchor.isActive = true
    }

    if edges.contains(.top) {
      let topAnchor = subview.topAnchor.constraint(equalTo: view.topAnchor)
      topAnchor.priority = UINSLayoutPriority(priority)
      topAnchor.isActive = true
    }

    if edges.contains(.bottom) {
      let bottomAnchor = subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      bottomAnchor.priority = UINSLayoutPriority(priority)
      bottomAnchor.isActive = true
    }

    if centering.contains(.horizontal) {
      let horizontalAnchor = subview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      horizontalAnchor.priority = UINSLayoutPriority(priority)
      horizontalAnchor.isActive = true
    }

    if centering.contains(.vertical) {
      let verticalAnchor = subview.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      verticalAnchor.priority = UINSLayoutPriority(priority)
      verticalAnchor.isActive = true
    }
  }
}




public extension UINSColor {
  static var random: UINSColor {
    return UINSColor(
      red: .random(in: 0 ... 1),
      green: .random(in: 0 ... 1),
      blue: .random(in: 0 ... 1),
      alpha: 1.0
    )
  }


  var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    #if TARGET_OS_OSX
    let color = self.usingColorSpace(.displayP3) ?? { assertionFailure(); return UINSColor.gray }()
    #else // if canImport(UIKit)
    let color = self
    #endif
    color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return (h, s, b, a)
  }


  func adaptedToMode(_ commonValue: CGFloat? = nil, light: CGFloat? = nil, dark: CGFloat? = nil) -> UINSColor {
    let hsba = self.hsba
    let isLight = UINSColor.isLightMode

    let lightModeValue: CGFloat? = isLight ? (light ?? commonValue) : nil
    let darkModeValue: CGFloat? = (!isLight) ? (dark ?? commonValue) : nil

    let saturationValue: CGFloat = (lightModeValue ?? 1.0) * hsba.saturation
    let brightnessValue: CGFloat = (darkModeValue ?? 1.0) * hsba.brightness

    return UINSColor(hue: hsba.hue, saturation: saturationValue, brightness: brightnessValue, alpha: hsba.alpha)
  }

  // public static var isLight: Bool {
  //   var light: Bool = true
  //   _ = UIColor{ light = ( $0.userInterfaceStyle == .light ); return .black }
  //   return light
  // }
  // public static var isDark: Bool { !isLight }
}

public extension UINSColor {
  // from: https://theswiftdev.com/2018/05/03/uicolor-best-practices-in-swift/

  struct RGBA {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
  }

  // var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
  var rgba: UINSColor.RGBA {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    // return (r, g, b, a)
    return RGBA(red: r, green: g, blue: b, alpha: a)
  }
}




public class VerticallyCenteredTextView: UINSTextView {
  // public override init(frame: NSRect, textContainer: NSTextContainer?) {
  //   super.init(frame: frame, textContainer: textContainer)
  // }
  #if canImport(UIKit)
  override public var contentSize: CGSize {
    didSet {
      var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
      topCorrection = max(0, topCorrection)
      contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
    }
  }
  // https://geek-is-stupid.github.io/2017-05-15-how-to-center-text-vertically-in-a-uitextview/
  #endif
}

#if Disabled
public extension UINSApplication {
  // Presenting An Alert on both platforms
  static func presentAlert(_ alert: UINSAlertController) {
    #if os(iOS)
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: { })

    #elseif os(macOS)
    let modalResult = alert.runModal()

    switch modalResult {
      case NSApplication.ModalResponse.alertFirstButtonReturn:
      NSAlert.buttonActionHandlers[0](0)
      case NSApplication.ModalResponse.alertSecondButtonReturn:
      NSAlert.buttonActionHandlers[1](1)
      case NSApplication.ModalResponse.alertThirdButtonReturn:
      NSAlert.buttonActionHandlers[2](2)
      default:
      print("unexpected")
    }
    NSAlert.buttonActionHandlers.removeAll()
    #else
    #endif
  }
}

#endif 


#if os(iOS)

extension UITextInput {
  var selectedRange: NSRange? {
    guard let range = selectedTextRange else { return nil }
    let location = offset(from: beginningOfDocument, to: range.start)
    let length = offset(from: range.start, to: range.end)
    return NSRange(location: location, length: length)
    // https://gist.github.com/gkhackers/d511b0bd070960191da5390a4e028d65
  }

  func nsRange(uiRange: UITextRange) -> NSRange {
    let location = offset(from: beginningOfDocument, to: uiRange.start)
    let length = offset(from: uiRange.start, to: uiRange.end)
    return NSRange(location: location, length: length)
  }


  func uiTextRange(nsRange: NSRange) -> UITextRange? {
    let location = nsRange.location
    let length = nsRange.length

    guard let startPosition = position(from: beginningOfDocument, offset: location),
          let endPosition = position(from: beginningOfDocument, offset: location + length) else { return nil }
    return textRange(from: startPosition, to: endPosition)
  }
}

public extension NSTextRange {
  convenience init?(_ range: NSRange, provider: NSTextElementProvider) {
    let docLocation = provider.documentRange.location

    guard let start = provider.location?(docLocation, offsetBy: range.location) else {
      return nil
    }

    guard let end = provider.location?(start, offsetBy: range.length) else {
      return nil
    }

    self.init(location: start, end: end)
  }
  // https://github.com/ChimeHQ/Rearrange/blob/b83fb77f2202256a4439aa148134d3b28e3f00d2/Sources/Rearrange/NSTextRange%2BNSRange.swift
}

public extension NSTextElementProvider {
  func nsTextRange(from range: NSRange) -> NSTextRange? {
    let provider = self
    let docLocation = provider.documentRange.location

    guard let start = provider.location?(docLocation, offsetBy: range.location) else {
      return nil
    }

    guard let end = provider.location?(start, offsetBy: range.length) else {
      return nil
    }

    return NSTextRange(location: start, end: end)
  }
}
#elseif os(macOS)
import AppKit
public extension NSTextView {
  func nsTextRange(from range: NSRange) -> NSTextRange? {
    
    guard let docLocation = self.textLayoutManager?.documentRange.location else { return nil }
    
    guard let start = self.textLayoutManager?.location(docLocation, offsetBy: range.location) else {
      return nil
    }

    guard let end = self.textLayoutManager?.location(start, offsetBy: range.length) else {
      return nil
    }

    return NSTextRange(location: start, end: end)
  }
}
#endif

public extension UINSTextView {
  func uinsCurrentCursorRect() -> CGRect? {
#if os(iOS)
    guard let range = self.selectedTextRange else { return nil }
    let cursorRect = textView.caretRect(for: range.start)
    return cursorRect
#elseif os(macOS)
    
    var cursorRect: CGRect?
    
    let nsr = self.selectedRange()
    if let textRange = self.nsTextRange(from: nsr) {
      // var loc = textRange.location
      
      textLayoutManager?.enumerateTextSegments(
        in: textRange,
        type: .standard,
        options: .upstreamAffinity) {
          _,
          segmentFrame,
          baselinePosition,
          _ in
          // use segmentFrame and baselinePosition to calculate insertion point location in NSTextContainer
          cursorRect = segmentFrame
          return false
        }
    }
    return cursorRect
#endif
  }
}
