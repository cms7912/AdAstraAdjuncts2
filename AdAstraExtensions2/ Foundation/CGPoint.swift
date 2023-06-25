//
//  File.swift
//  
//
//  Created by cms on 1/2/22.
//
  
import Foundation
import CoreGraphics



extension CGPoint: DebugDescription {
	public var dd: String { "X: \(self.x) Y: \(self.y)" }
}

public extension CGPoint {

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(
			x: lhs.x + rhs.x,
			y: lhs.y + rhs.y
		)
	}
	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(
			x: lhs.x - rhs.x,
			y: lhs.y - rhs.y
		)
	}

	static func + (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(
			x: lhs.x + rhs,
			y: lhs.y + rhs
		)
	}
	static func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(
			x: lhs.x - rhs,
			y: lhs.y - rhs
		)
	}

	static func - (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
		return CGPoint(
			x: lhs - rhs.x,
			y: lhs - rhs.y
		)
	}

	static func + (lhs: CGFloat, rhs: CGPoint) -> CGPoint { rhs + lhs }


	static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(
			x: lhs.x * rhs,
			y: lhs.y * rhs
		)
	}
	static func * (lhs: CGPoint, rhs: Double) -> CGPoint { lhs * CGFloat(rhs) }
	static func * (lhs: CGPoint, rhs: Int) -> CGPoint { lhs * CGFloat(rhs) }

	static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(
			x: lhs.x * rhs.x,
			y: lhs.y * rhs.y
		)
	}


	static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(
			x: lhs.x / rhs,
			y: lhs.y / rhs
		)
	}
	static func / (lhs: CGPoint, rhs: Double) -> CGPoint { lhs / CGFloat(rhs) }
	static func / (lhs: CGPoint, rhs: Int) -> CGPoint { lhs / CGFloat(rhs) }


	static func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		func parse(_ left: CGFloat, _ right: CGFloat) -> CGFloat {
			if left == 0 { return 0}
			if right == 0 { return 0 } // avoids divide by zero crash. But is this desired behavior?
			return left/right
		}
		return CGPoint(
			x: parse(lhs.x , rhs.x),
			y: parse(lhs.y, rhs.y)
		)
	}

	var asCGSize: CGSize { CGSize(w: self.x, h: self.y) }

	func within(_ withinDistance: CGFloat, of point: CGPoint) -> Bool {
		let xDist = (self.x - point.x)
		let yDist = (self.y - point.y)
		let actualDistance = sqrt((xDist * xDist) + (yDist * yDist))

		return (actualDistance <= withinDistance)
	}

}

public extension Optional where Wrapped == CGPoint {
	var asZeroIfNil: CGPoint {
		guard let unwrapped = self else {
			return .zero
		}
		return unwrapped
	}

	var asNilIfZero: CGPoint? {
		guard let unwrapped = self, unwrapped != .zero else {
			return nil
		}
		return unwrapped
	}
}

