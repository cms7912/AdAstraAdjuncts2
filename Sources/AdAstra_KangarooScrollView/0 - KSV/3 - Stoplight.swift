//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions


public struct Stoplight: Equatable, DebugDescription {
	public init(map: Map, notchIndex: Int, divotIndex: Int) {
		self.map = map
		self.notchIndex = notchIndex
		self.divotIndex = divotIndex
	}

	public static func == (lhs: Stoplight, rhs: Stoplight) -> Bool {
		return (lhs.map.mapID == rhs.map.mapID &&
						lhs.notchIndex == rhs.notchIndex &&
						lhs.divotIndex == rhs.divotIndex)
	}

	public var map: any Map
	public var notchIndex: Int
	public var divotIndex: Int

	public var notchPosition: CGFloat? {
		return map[notchIndex: notchIndex]
	}
	public var divotPosition: CGFloat? {
		return map[divotIndex: divotIndex]
	}


	var notchPositionBinding: Binding<CGFloat> { Binding(getOnly: { notchPosition.unwrapAssertOr(0) }) }
	var divotPositionBinding: Binding<CGFloat> { Binding(getOnly: { divotPosition.unwrapAssertOr(0) }) }

	public var dd: String {
		"Notch \(notchIndex.dd): \(notchPosition.dd)" +
		"  Divot \(divotIndex.dd): \(divotPosition.dd)"
	}
}


