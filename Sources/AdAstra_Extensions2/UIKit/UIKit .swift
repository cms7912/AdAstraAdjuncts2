//
//  UIView  .swift
//  UIView
//
//  Created by cms on 9/17/21.
//
import Foundation
import SwiftUI

#if os(iOS)
import UIKit

// import AdAstraBridgingByShim

extension UIResponder {
  private weak static var _currentFirstResponder: UIResponder?

  public static var currentFirstResponder: UIResponder? {
    UIResponder._currentFirstResponder = nil
    UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
    return UIResponder._currentFirstResponder
  }

  @objc internal func findFirstResponder(sender _: AnyObject) {
    UIResponder._currentFirstResponder = self
  }
}

/*
 extension UIView {

 public func addSubviewWithAnchorConstraints(_ subview: UIView,
 edges: [Edge] = Edge.allCases,
 priority: Float = 1000) {
 let view = self

 subview.willMove(toSuperview: view)
 view.addSubview(subview)
 subview.didMoveToSuperview()

 subview.translatesAutoresizingMaskIntoConstraints = false
 // subview always needs translatesAutoresizingMaskIntoConstraints turned off.
 // the parent view could need it, but can be set at site of call when needed

 let leadingAnchor = subview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
 leadingAnchor.priority = UILayoutPriority(priority)
 leadingAnchor.isActive = true

 let trailingAnchor = subview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
 trailingAnchor.priority = UILayoutPriority(priority)
 trailingAnchor.isActive = true

 let topAnchor = subview.topAnchor.constraint(equalTo: view.topAnchor)
 topAnchor.priority = UILayoutPriority(priority)
 topAnchor.isActive = true

 let bottomAnchor = subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
 bottomAnchor.priority = UILayoutPriority(priority)
 bottomAnchor.isActive = true

 }

 }
 */


public extension UISplitViewController {
  func showSidebar() {
    show(UISplitViewController.Column.primary)
  }

  func hideSidebar() {
    hide(UISplitViewController.Column.primary)
  }

  func toggleSidebar() {
    if isCollapsed {
      showSidebar()
    } else {
      hideSidebar()
    }
  }

  var isExpanded: Bool { !isCollapsed }
}

public extension Bundle {
  var icon: UIImage? {
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
       let lastIcon = iconFiles.last
    {
      return UIImage(named: lastIcon)
    }
    return nil
  }
  // https://stackoverflow.com/questions/9419261/how-to-get-the-current-application-icon-in-ios
}


public extension UITextView {
  var fullTextRange: UITextRange? {
    let textInput = self
    if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: 0),
       let rangeEnd = textInput.position(from: rangeStart, offset: textInput.textStorage.length)
    {
      return textInput.textRange(from: rangeStart, to: rangeEnd)
    }
    return nil
  }
  // https://stackoverflow.com/questions/9126709/create-uitextrange-from-nsrange
}


public extension UIColor {
  static var aaSystemGray2: UIColor { .systemGray2 }
  static var aaSystemGray3: UIColor { .systemGray3 }
  static var aaSystemGray4: UIColor { .systemGray4 }
  static var aaSystemGray5: UIColor { .systemGray5 }
  static var aaSystemGray6: UIColor { .systemGray6 }
  static var aaQuaternaryLabel: UIColor { .quaternaryLabel }
  static var aaQuaternarySystemFill: UIColor { .quaternarySystemFill }
  static var aaSeparator: UIColor { .separator }
  static var aaOpaqueSeparator: UIColor { .opaqueSeparator }
  static var aaSecondarySystemFill: UIColor { .secondarySystemFill }
  static var aaTertiarySystemFill: UIColor { .tertiarySystemFill }
  static var aaTertiarySystemBackground: UIColor { .tertiarySystemBackground }
  static var aaSecondarySystemGroupedBackground: UIColor { .secondarySystemGroupedBackground }
  static var aaTertiarySystemGroupedBackground: UIColor { .tertiarySystemGroupedBackground }
}

#endif

