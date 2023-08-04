//
//  File.swift
//  
//
//  Created by cms on 2/28/22.
//

import Foundation
import AdAstraExtensions
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension MapUsingStoredStrides {

	// the StrideMetadata is stored as generic protocol and absolute/relative distinction only needed in updateStopPositions().  So this first function tests for 'AbsoluteStrideMetadata' or 'RelativeStrideMetadata' and calls the appropriate updateStopPositions().
	// (I wish this function would simply be overloaded with two call interfaces, then the call site would simply pass in the generic metadata and the appropriate function would get used. But that doesn't seem to work)

	func updateStopPositions(
		_ viewLength: CGFloat?,
		_ metadata: StrideMetadata,
		_ positionsStore: inout [CGFloat]?) -> [CGFloat] {

			if let metadata = metadata as? AbsoluteStrideMetadata {
				return updateStopPositions( viewLength, metadata, &positionsStore)
			} else if let metadata = metadata as? RelativeStrideMetadata {
				return updateStopPositions( viewLength, metadata, &positionsStore)
			}
			assert(false)
			return [CGFloat]()
		}



	// Absolute
	@discardableResult
	func updateStopPositions(
		_ viewLength: CGFloat?,
		_ metadata: AbsoluteStrideMetadata,
		_ positionsStore: inout [CGFloat]?) -> [CGFloat] {
			var newPositions = [CGFloat]()
			if let viewLength = viewLength {
				let stopInterval = metadata.stopInterval <= 1 ? .infinity : metadata.stopInterval
				newPositions = stride(
					from: metadata.firstStop,
					through: viewLength,
					by: stopInterval).map{$0}
			}
			positionsStore = newPositions
			llog("newPositions: \(newPositions.count)")
			return newPositions
		}
	// }


	// Relative
	@discardableResult
	func updateStopPositions(
		_ viewLength: CGFloat?,
		_ metadata: RelativeStrideMetadata,
		_ positionsStore: inout [CGFloat]?) -> [CGFloat] {
			assert((0 ... 1.0).contains(metadata.firstStop) )
			var newPositions = [CGFloat]()
			if let viewLength = viewLength, metadata.stopCount != 0 {
				let stopCount = (metadata.stopCount <= 1) || (metadata.stopCount == .infinity) ? 1 : metadata.stopCount

				// 'firstStop' is a percentage of the stride length
				let relativeFirstStop = (1.0/stopCount) * metadata.firstStop

				let newRelativePositions = stride(
					// from: metadata.firstStop, // will be relative
					from: relativeFirstStop ,
					through: 1.0,
					by: 1.0/stopCount).map{$0}
				newPositions = newRelativePositions.map{$0 * viewLength}
			}
			positionsStore = newPositions
			return newPositions
		}
}



