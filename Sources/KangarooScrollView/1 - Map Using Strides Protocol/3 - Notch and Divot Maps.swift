//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public protocol NotchStridesMapProtocol: MapUsingStoredStrides { }
extension NotchStridesMapProtocol {
	func setupPaneSubscription(){
		setupViewSubscription(view: ksvScrollManager?.$paneLength){ _ in self.notchPositionsStore = nil }
	}

	public var notchPositions: [CGFloat] {
		notchPositionsStore ?? updateNotchPositions()
	}
	public func notchPositionsChanged(){ notchPositionsStore = nil }

	var paneLength: CGFloat? {ksvScrollManager?.paneLength }

	@discardableResult
	func updateNotchPositions() -> [CGFloat] {
		let n = updateStopPositions(paneLength, notchStrideMetadata, &notchPositionsStore)
		_ = true
		return n
	}
}


public protocol DivotStridesMapProtocol: MapUsingStoredStrides { }
extension DivotStridesMapProtocol {
	func setupContentSubscription(){
		setupViewSubscription(view: ksvScrollManager?.$contentLength) { _ in self.divotPositionsStore = nil }
	}

	public var divotPositions: [CGFloat] {
		divotPositionsStore ?? updateDivotPositions()
	}
	public func divotPositionsChanged(){ divotPositionsStore = nil }

	var contentLength: CGFloat? {ksvScrollManager?.contentLength }

	@discardableResult
	func updateDivotPositions() -> [CGFloat] {
		let n = updateStopPositions(contentLength, divotStrideMetadata, &divotPositionsStore)
		_ = true
		return n
	}

}
