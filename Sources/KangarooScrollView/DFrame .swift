//
//  File.swift
//  
//
//  Created by cms on 4/11/22.
//

import Foundation
import SwiftUI

private struct ScrollDirectionKey: EnvironmentKey {
	static let defaultValue = Axis.Set.horizontal
}
extension EnvironmentValues {
	var scrollDirection: Axis.Set {
		get { self[ScrollDirectionKey.self] }
		set { self[ScrollDirectionKey.self] = newValue }
	}
}
extension View {
	func scrollDirection(_ newScrollDirection: Axis.Set) -> some View {
		environment(\.scrollDirection, newScrollDirection)
	}
}


struct DFrame: ViewModifier {
	@Environment(\.scrollDirection) var scrollDirection

	var withScrollDirection: CGSize?
	var oppoScrollDirection: CGSize?
	var alignment: Alignment?

	@ViewBuilder
	func body(content: Content) -> some View {
		if alignment.isNil {
			bodyWithoutAlignment(content: content)
		} else {
			bodyWithAlignment(content: content)
		}
	}

	func bodyWithAlignment(content: Content) -> some View {
		content
			.frame(width: scrollDirection.isHorizontal ? withScrollDirection?.width : oppoScrollDirection?.width,
						 height: scrollDirection.isVertical ? withScrollDirection?.height : oppoScrollDirection?.height,
						 alignment: alignment ?? .center) // will never be nil, but unwrap to .center just to be safe
	}

	func bodyWithoutAlignment(content: Content) -> some View {
		content
			.frame(width: scrollDirection.isHorizontal ? withScrollDirection?.width : oppoScrollDirection?.width,
						 height: scrollDirection.isVertical ? withScrollDirection?.height : oppoScrollDirection?.height)
	}

}

public extension View {
	func dframe(
		withScrollDirection: CGSize?,
		oppoScrollDirection: CGSize?,
		alignment: Alignment?

	) -> some View {
		self.modifier(DFrame(withScrollDirection: withScrollDirection,
												 oppoScrollDirection: oppoScrollDirection,
												 alignment: alignment )
		)
	}

	// func dframe(_ fcs: DFrameSize) {
 //
	// }
}





 
