//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
import AdAstraExtensions
import SwiftUI

public protocol Map: AnyObject, LLogging {
	var ksvScrollManager: KSVScrollManager? { get set }
	var mapID: UUID { get }
	// var id: UUID { get } //{mapID}


	subscript(notchIndex index: Int) -> CGFloat? { get }
	subscript(divotIndex index: Int) -> CGFloat? { get }
	// for KSV, maps only need to answer position of notch/divot at given index. Further sub-protocols implement storing positions and on-demand recalculating.

	func bestStoplight() -> Stoplight?

	// static func == (lhs: Self, rhs: any Map) -> Bool

	func notchPositionsChanged()
	func divotPositionsChanged()
}

// extension Map: Equatable {
	// static func ==<T: Map> (lhs: Map, rhs: T) -> Bool {
 //    lhs.id == rhs.id
 //  }

	// public var id: UUID {mapID}
// }

extension Map {
	var direction: Axis.Set? { ksvScrollManager?.direction }
	var contentLength: CGFloat? { ksvScrollManager?.contentLength }
	public var offsetRaw: CGFloat? {
		guard let direction = direction else { return nil }
		return ksvScrollManager?.rawContentRect?.origin.for(direction)
	}
	public var offset: CGFloat? {
		guard let direction = direction else { return nil }
		return -1 * ksvScrollManager?.rawContentRect?.origin.for(direction)
	}


}


public protocol MapWithPositions: Map {
	var notchPositions: [CGFloat] { get }
	var divotPositions: [CGFloat] { get }
}
