//
//  File.swift
//  
//
//  Created by cms on 12/14/21.
//

import Foundation
import SwiftUI

public struct Divider: View {
  let edges: Edge.Set
  let length: CGFloat?
  public init(paddingOnly edges: Edge.Set = .all, length: CGFloat? = nil) {
    self.edges = edges
    self.length = length
  }
  
  public var body: some View {
    SwiftUI.Divider()
      .frame(width: 0, height: 0)
      .hidden()
      // .foregroundColor(.clear)
      .padding(edges, length)
  }
}
public extension View {
#if os(iOS)
	func snapshot() -> UIImage? {
		let controller = UIHostingController(rootView: self)
		guard let view = controller.view else { return nil }

		let targetSize = controller.view.intrinsicContentSize
		view.bounds = CGRect(origin: .zero, size: targetSize)
		view.backgroundColor = .clear

		let renderer = UIGraphicsImageRenderer(size: targetSize)

		return renderer.image { _ in
			view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
		}
		// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
	}
#elseif os(macOS)
	func snapshot() -> NSImage? {

		let controller = NSHostingController(rootView: self)
		let view = controller.view

		let targetSize = controller.view.intrinsicContentSize
		view.bounds = CGRect(origin: .zero, size: targetSize)
//		view.backgroundColor = .clear

		if let imageRepresentation = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
		view.cacheDisplay(in: view.bounds, to: imageRepresentation)
		return NSImage(cgImage: imageRepresentation.cgImage!, size: view.bounds.size)
		}
		return nil
	}
#endif

}



// MARK: - Flip ColorScheme

struct FlipColorScheme: ViewModifier {
	@Environment(\.colorScheme) var systemColorScheme

	@State var useOppositeColorScheme: Bool
	var oppositeColorScheme: ColorScheme {
		switch systemColorScheme {
			case .light:
				return .dark
			case .dark:
				return .light
			default:
				return .dark
		}
	}

	@ViewBuilder
	func body(content: Content) -> some View {
		content
			.colorScheme( useOppositeColorScheme ? oppositeColorScheme : systemColorScheme )
	}
}

public extension View {
	func flipColorScheme(_ useOpposite: Bool = true) -> some View {
		self.modifier(FlipColorScheme(useOppositeColorScheme: useOpposite))
	}
}





// MARK: - Fixed Size -> Ideal Size


public extension View {
	func trueSize(horizontal: Bool = true, vertical: Bool = true) -> some View {
		self.fixedSize(horizontal: horizontal, vertical: vertical)
	// https://www.swiftjectivec.com/swiftui-modifier-monday-fixedsize/
	}
}






public struct EmptyViewAssert: View {
	public init(_ assertion: Bool = false) {
		self.assertion = assertion
	}
	var assertion: Bool
	public var body: some View {
		assert(assertion)
		return EmptyView()
	}
}


struct IsVisible: ViewModifier {
  @Binding var valueIsTrue: Bool
  
  @ViewBuilder
  func body(content: Content) -> some View {
    if valueIsTrue {
      content
    } else {
      content.hidden()
    }
  }
}
public extension View {
  func isVisible(_ valueIsTrue: Binding<Bool> = .constant(true)) -> some View {
    self.modifier(IsVisible(valueIsTrue: valueIsTrue))
  }
  func isVisible(_ valueIsTrue: Bool = true) -> some View {
    self.modifier(IsVisible(valueIsTrue:
                              Binding(getOnly:
                              {valueIsTrue})
                            ))
  }

}
