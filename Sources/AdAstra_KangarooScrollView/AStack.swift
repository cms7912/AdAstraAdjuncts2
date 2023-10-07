//
//  File.swift
//  
//
//  Created by cms on 1/2/22.
//

import Foundation
import SwiftUI


// Axis Stack
// provides for setting horizontal/vertical stack contextually

public struct AStack<Content: View>: View {
	var scrollDirection: Axis.Set
	var alignment: Alignment
	var spacing: CGFloat
	var content: Content

	public init(
		_ scrollDirection: Axis.Set,
		alignment: Alignment =  Alignment(horizontal: .center, vertical: .center) , // .center ,
		spacing: CGFloat = 0,
		@ViewBuilder content: () -> Content
	) {
		self.scrollDirection = scrollDirection
		self.alignment = alignment
		self.spacing = spacing
		self.content = content()
	}


	public var body: some View {
		if scrollDirection == Axis.Set.horizontal {
			HStack(alignment: alignment.vertical, spacing: spacing ) {
				content
			}
		} else if scrollDirection == Axis.Set.vertical {
			VStack(alignment: alignment.horizontal, spacing: spacing ) {
				content
			}
		}
	}
}


public struct LazyAStack<Content: View>: View {
	var scrollDirection: Axis.Set
	var alignment: Alignment
	var spacing: CGFloat
	var content: Content

	public init(
		_ scrollDirection: Axis.Set,
		alignment: Alignment =  Alignment(horizontal: .center, vertical: .center) , // .center ,
		spacing: CGFloat = 0,
		@ViewBuilder content: () -> Content
	) {
		self.scrollDirection = scrollDirection
		self.alignment = alignment
		self.spacing = spacing
		self.content = content()
	}


	public var body: some View {
		if scrollDirection == Axis.Set.horizontal {
			LazyHStack(alignment: alignment.vertical, spacing: spacing ) {
				content
			}
		} else if scrollDirection == Axis.Set.vertical {
			LazyVStack(alignment: alignment.horizontal, spacing: spacing ) {
				content
			}
		}
	}
}

// MARK: - View Modifier

struct AFrameModifierView: ViewModifier {
	var direction: Axis.Set
	var size: CGFloat
	@ViewBuilder
	func body(content: Content) -> some View {
		content
			.frame(width: direction.isHorizontal ? size : nil ,
						 height: direction.isVertical ? size : nil
			)
	}
}
public extension View {
	func aframe(_ direction: Axis.Set, _ size: CGFloat) -> some View {
		self.modifier(AFrameModifierView(direction: direction, size: size))
	}
	func aframe(_ direction: Axis.Set, _ size: CGSize) -> some View {
		self.modifier(AFrameModifierView(direction: direction, size: size.forDimension(direction)))
	}

}
