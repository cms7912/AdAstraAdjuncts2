//
//  File.swift
//  
//
//  Created by cms on 12/9/21.
//

import Foundation
#if os(macOS)
import AppKit
import SwiftUI

// typealias VerticallyCenteredTextView = NSTextView



public class VerticallyCenteredTextView: NSTextView {
  
}

extension NSTextView {
  // Removes default immutable background from TextEditor()
  open override var frame: CGRect {
    didSet {
      backgroundColor = .clear
      drawsBackground = true
    }
  }
  //https://developer.apple.com/forums/thread/659788
}

// public extension CGRect {
// 	var flippedY: CGRect {
// 		// CGRect(
// 		// 	x: minX,
// 		// 	y: minY,
// 		// 	width: width,
// 		// 	height: height)
// 		self
// 	}
// }
import SwiftUI

  
public extension NSAttributedString {
  var withLabelColor: NSAttributedString {
    let mas = NSMutableAttributedString(attributedString: self)
    mas.addAttribute(.foregroundColor,
//                     value: NSColor.label,
                     value: NSColor.labelColor,
                     // value: NSColor.systemRed,
                     range: fullRange)
    
    return mas.attributedSubstring(from: fullRange)
  }
  
  convenience init(stringWithLabelColor string: String){
//    self.init(string: string, attributes: [.foregroundColor : NSColor.label])
    self.init(string: string, attributes: [.foregroundColor : NSColor.labelColor])
  }
}


#endif
