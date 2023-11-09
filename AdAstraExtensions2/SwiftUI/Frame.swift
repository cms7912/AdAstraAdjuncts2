// 2022-09-26

import SwiftUI

public extension View {
	func frame(_ size: CGSize?) -> some View {
    Group{
      if let size {
        self.frame(width: size.width, height: size.height)
      } else {
        self.frame(width: nil, height: nil)
        
      }
    }
	}
	func frame(w: CGFloat, h: CGFloat) -> some View {
		self.frame(width: w, height: h)
	}
	func frame(w: CGFloat) -> some View {
		self.frame(width: w)
	}
	func frame(h: CGFloat) -> some View {
		self.frame(height: h)
	}


}
