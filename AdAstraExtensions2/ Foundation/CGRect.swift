//
//  File.swift
//  
//
//  Created by cms on 1/3/22.
//

import Foundation
import CoreGraphics

extension CGRect {


}

public extension Optional where Wrapped == CGRect {
	var asZeroIfNil: CGRect {
		guard let unwrapped = self else {
			return .zero
		}
		return unwrapped
	}

	var asNilIfZero: CGRect? {
		guard let unwrapped = self, unwrapped != .zero else {
			return nil
		}
		return unwrapped
	}

	var size: CGSize? {
		guard let unwrapped = self else { return nil }
		return unwrapped.size
		// makes for cleaner log statements without optional string warning
	}
}
