//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
import CoreGraphics

extension CGSize: DebugDescription {
  public var dd: String { "W: \(self.width) H: \(self.height)" }
}

public extension CGSize {
  init(w: CGFloat, h: CGFloat) {
    self.init(width: w, height: h)
  }
  init(w: Double, h: Double) {
    self.init(width: w, height: h)
  }
  init(w: Int, h: Int) {
    self.init(width: w, height: h)
  }

	static func square(_ v: CGFloat) -> CGSize {
		CGSize(w: v, h: v)
	}

	var greatestDimension: CGFloat {
		width > height ? width : height
	}
	
    func scale(by factor: CGFloat) -> CGSize {
        CGSize(width:
                self.width * factor
               ,height:
                self.height * factor
        )
    }
 //    func cropSizeToWithin(maxSize maxDimensions: CGSize) -> CGSize {
 //        CGSize(
 //            width: self.width <= maxDimensions.width ? self.width : maxDimensions.width
 //            , height: self.height <= maxDimensions.height ? self.height : maxDimensions.height
 //        )
 //    }
 //    func stretchSizeToAbove(minSize minDimensions: CGSize) -> CGSize {
 //        CGSize(
 //            width: self.width >= minDimensions.width ? self.width : minDimensions.width
 //            , height: self.height >= minDimensions.height ? self.height : minDimensions.height
 //        )
 //    }
	// func scaleSizeToAbove(minSize: CGSize) -> CGSize {
	// 	// CGSize(
	// 	// 	width: self.width >= minDimensions.width ? self.width : minDimensions.width
	// 	// 	, height: self.height >= minDimensions.height ? self.height : minDimensions.height
	// 	// )
	// 	let deltaWidth = minSize.width - self.width
	// 	let deltaHeight = minSize.height - self.height
 //
	// 	guard deltaWidth > 0 || deltaHeight > 0 else { return self }
	// 	if deltaWidth > deltaHeight {
	// 		// bigger width difference
 //
	// 	} else {
	// 		// bigger height difference
	// 	}
	// }
 //
	// /// scales both dimensions by given factor, respecting max and min limits
 //    func resizeUsing_OLD(_ factor: CGFloat
 //                     , max maxDimensions: CGSize? = nil
 //                     , min minDimensions: CGSize? = nil
 //    ) -> CGSize {
 //        let rescaledSize = self.scale(by: factor)
 //
	// 		if let minSize = minDimensions {
 //
	// 		}
 //        let minimumSize = rescaledSize.stretchSizeToAbove(minSize: minDimensions)
 //        let constrainedSize = minimumSize.cropSizeToWithin(maxSize: maxDimensions)
 //        return constrainedSize
 //    }

    // func rescaleToFitWithin(maxSize: CGSize) -> CGSize {
    //     if self.width > self.height {
    //         let newHeight = (maxSize.width/self.width) * self.height
    //         return CGSize(w: maxSize.width, h: newHeight)
    //     } else {
    //         let newWidth = (maxSize.height/self.height) * self.width
    //         return CGSize(w: newWidth, h: maxSize.height)
    //     }
    // }

    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }
    
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(
            width: lhs.width * rhs,
            height: lhs.height * rhs
        )
    }
    static func * (lhs: CGSize, rhs: Double) -> CGSize { lhs * CGFloat(rhs) }
    static func * (lhs: CGSize, rhs: Int) -> CGSize { lhs * CGFloat(rhs) }
    
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(
            width: lhs.width * rhs.width,
            height: lhs.height * rhs.height
        )
    }

    
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(
            width: lhs.width / rhs,
            height: lhs.height / rhs
        )
    }
    static func / (lhs: CGSize, rhs: Double) -> CGSize { lhs / CGFloat(rhs) }
    static func / (lhs: CGSize, rhs: Int) -> CGSize { lhs / CGFloat(rhs) }

    
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        func parse(_ left: CGFloat, _ right: CGFloat) -> CGFloat {
            if left == 0 { return 0}
            if right == 0 { return 0 } // avoids divide by zero crash. But is this desired behavior?
            return left/right
        }
        return CGSize(
            width: parse(lhs.width , rhs.width),
            height: parse(lhs.height, rhs.height)
        )
    }

    
    static func maxes(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(
            width: Swift.max(lhs.width, rhs.width),
            height: Swift.max(lhs.height, rhs.height)
        )
    }
    
    
    
    var asCGPoint: CGPoint { CGPoint(x: self.width, y: self.height) }
    static func +(lhs: CGSize, rhs: CGPoint) -> CGSize {
        CGSize(
            w: lhs.width + rhs.y,
            h: lhs.height + rhs.y
        )
    }

	var inverted: CGSize {
		return CGSize(
			width: self.height,
			height: self.width
		)
	}


}


public extension Optional where Wrapped == CGSize {
	var asZeroIfNil: CGSize {
		guard let unwrapped = self else {
			return .zero
		}
		return unwrapped
	}

	var asNilIfZero: CGSize? {
		guard let unwrapped = self, unwrapped != .zero else {
			return nil
		}
		return unwrapped

	}
}



// MARK: - Aspect Scaling
public extension CGSize{
	func aspectFit(into size: CGSize) -> CGSize {
		if self.width == 0.0 || self.height == 0.0 {
			return self
		}

		let widthRatio = size.width / self.width
		let heightRatio = size.height / self.height
		let aspectFitRatio = min(widthRatio, heightRatio)
		return CGSize(width: self.width * aspectFitRatio, height: self.height * aspectFitRatio)
	}

	func aspectFill(into size: CGSize) -> CGSize {
		if self.width == 0.0 || self.height == 0.0 {
			return self
		}

		let widthRatio = size.width / self.width
		let heightRatio = size.height / self.height
		let aspectFillRatio = max(widthRatio, heightRatio)
		return CGSize(width: self.width * aspectFillRatio, height: self.height * aspectFillRatio)
	}
//https://github.com/bugnitude/CGSize-AspectRatio/blob/master/CGSize%2BAspectRatio.swift
}


// Mark: - Bounded Scaling
public extension CGSize {
	func isSmallerThan(_ size: CGSize) -> Bool {
		self.width <= size.width && self.height <= size.height
	}

	func isLargerThan(_ size: CGSize) -> Bool {
		self.width >= size.width && self.height >= size.height
	}

	func minimumFit(_ minSize: CGSize) -> CGSize {
		if self.isSmallerThan(minSize){
			return self.aspectFit(into: minSize)
		}
		return self
	}
	func maximumFit(_ maxSize: CGSize) -> CGSize {
		if self.isLargerThan(maxSize){
			return self.aspectFit(into: maxSize)
		}
		return self
	}

	func resizeBy(_ factor: CGFloat
								, withMin minSize: CGSize? = nil
									 , withMax maxSize: CGSize? = nil
	) -> CGSize {
		var rescaledSize = self.scale(by: factor)

		if let minSize = minSize {
			rescaledSize = rescaledSize.minimumFit(minSize)
		}

		if let maxSize = maxSize {
			rescaledSize = rescaledSize.maximumFit(maxSize)
		}
		return rescaledSize

	}

}

import Combine
// public extension CGSize{
// 	var publisher: Publisher<CGSize> {
// 		Just(self)
// 		// .setFailureType(to: Error.self)
// 			.receive(on: DispatchQueue.main)
// 			.eraseToAnyPublisher()
// 	}
// }
