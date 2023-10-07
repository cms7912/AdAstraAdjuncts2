//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
import Combine
import SwiftUI

public protocol MapUsingStoredStrides: MapWithPositions {
	var notchStrideMetadata: StrideMetadata { get }
	var divotStrideMetadata: StrideMetadata { get }


	subscript(notchCaliper index: Int) -> CGFloat { get }
	subscript(divotCaliper index: Int) -> CGFloat { get }
	// calipers as subscripts allow concrete maps to return the same caliper or index-unique calipers, and stored or calculated

	var notchPositions: [CGFloat] { get }
	var divotPositions: [CGFloat] { get }
	var notchPositionsStore: [CGFloat]? { get set }
	var divotPositionsStore: [CGFloat]? { get set }
	// notch/divot positions need stored, not live calculations. the striding will be updated rarely. The pane/content resizing will be infrequent. But bestStoplight() will search the notch & divot positions frequently during every scroll

	var subscriptions: Set<AnyCancellable> { get set }
}
extension MapUsingStoredStrides {

	public subscript(notchIndex index: Int) -> CGFloat? { notchPositions[safeIndex: index] }
	public subscript(divotIndex index: Int) -> CGFloat? { divotPositions[safeIndex: index] }
}



extension MapUsingStoredStrides {
	// func setupViewSubscription(view: (Published<CGSize?>.Publisher)?, stopPositionsStore: inout [CGFloat]?){
	func setupViewSubscription(view: (CurrentValueSubject<CGFloat?, Never>)?, actionHandler: @escaping (CGFloat?) -> Void){
		view?
			.sink(receiveValue: actionHandler)
		// .sink{ _ in //
		// 	actionHandler()
		// }
			.store(in: &subscriptions)
	}
}

extension MapUsingStoredStrides {
	public func bestStoplight() -> Stoplight? {
		guard let offset = offset else { return nil }

		var bestStoplightYet: Stoplight?
		var bestStopDistanceYet: CGFloat = .infinity

		//Notches
		for currentNotchIndex in notchPositions.indices {
			let currentNotch = notchPositions[currentNotchIndex]
			let currentNotchAtOffset = currentNotch + offset

			var bestDistanceYet: CGFloat = .infinity
			//Divots
			for currentDivotIndex in divotPositions.indices {
				let currentDivot = divotPositions[currentDivotIndex]

				let divotDistance = abs(currentNotchAtOffset - currentDivot)

				guard divotDistance <= (self[notchCaliper: currentNotchIndex] + self[divotCaliper: currentDivotIndex] ) else { continue } // not within each other's calipers

				if bestDistanceYet > divotDistance ||
						self[divotCaliper: currentDivotIndex].isInfinite {
					bestDistanceYet = divotDistance
				}

				if bestStopDistanceYet > bestDistanceYet { // found better stop
					bestStoplightYet = Stoplight( map: self, notchIndex:  currentNotchIndex, divotIndex:  currentDivotIndex)
					bestStopDistanceYet = bestDistanceYet
				}

				if self[divotCaliper: currentDivotIndex].isInfinite { break }
			}
			if self[notchCaliper: currentNotchIndex].isInfinite { break }
		}

		return bestStoplightYet
	}

}



public protocol StrideMetadata {
	var firstStop: CGFloat { get }
}

public struct AbsoluteStrideMetadata: StrideMetadata {
	@Binding public var firstStop: CGFloat
	@Binding public var stopInterval: CGFloat
}
public struct RelativeStrideMetadata: StrideMetadata {
	@Binding public var firstStop: CGFloat
	@Binding public var stopCount: CGFloat
}
struct FailedStride: StrideMetadata { var firstStop: CGFloat = 0 }
