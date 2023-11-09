//
//  File 2.swift
//  
//
//  Created by cms on 8/28/22.
//

import Foundation

public protocol AdAstraFont {
  var ascender: CGFloat { get }
  var descender: CGFloat { get }
  var capHeight: CGFloat { get }
}
public extension AdAstraFont {
  var aaMaxHeightForFont: CGFloat {
    #if DEBUG
    assert(ascender > capHeight)
    #endif
		return (ascender + descender)
  }
  // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/FontHandling/Tasks/GettingFontMetrics.html
}

#if canImport(UIKit)
import UIKit
extension UIFont: AdAstraFont { }
#elseif canImport(AppKit)
import AppKit
extension NSFont: AdAstraFont { }
#endif
#if canImport(SwiftUI)
import SwiftUI
// extension Font: AdAstraFont { }
#endif
