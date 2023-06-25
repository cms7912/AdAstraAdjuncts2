//
//  File.swift
//
//
//  Created by cms on 1/2/22.
//

import Foundation
import SwiftUI

public extension CGPoint {
  func forDimension(_ dimension: Axis.Set) -> CGFloat {
    dimension.isHorizontal ? x : y
  }

  func `for`(_ dimension: Axis.Set) -> CGFloat { forDimension(dimension) }

  init(_ direction: Axis.Set, _ point: CGFloat, oppositeDimensionSize: CGFloat = 0) {
    self.init(x: direction.isHorizontal ? point : oppositeDimensionSize,
              y: direction.isVertical ? point : oppositeDimensionSize)
  }

  init(_ direction: Axis.Set, _ point: CGPoint, oppositeDimensionSize: CGFloat = 0) {
    self.init(x: direction.isHorizontal ? point.forDimension(direction) : oppositeDimensionSize,
              y: direction.isVertical ? point.forDimension(direction) : oppositeDimensionSize)
  }
}

public extension CGSize {
  func forDimension(_ dimension: Axis.Set) -> CGFloat {
    if dimension.isHorizontal { return width }
    if dimension.isVertical { return height }
//    NSObject.CrashAfterUserAlert("unexpected axis")
    fatalError()
  }

  func `for`(_ dimension: Axis.Set) -> CGFloat {
    forDimension(dimension) }
  // func `for`(_ dimension: Axis.Set?) -> CGFloat? {
  // 	guard let dimension = dimension else { return nil }
  // 	return forDimension(dimension) }
}

public extension Optional where Wrapped == CGSize {
  func `for`(_ dimension: Axis.Set?) -> CGFloat? {
    guard let size = self, let dimension = dimension else { return nil }
    return size.for(dimension) }
}

public extension Axis.Set {
  static prefix func ! (given: Axis.Set) -> Axis.Set {
    if given == .horizontal {
      return .vertical
    } else if given == .vertical {
      return .horizontal
    } else {
      // #if Debug
//      NSObject.CrashAfterUserAlert("unexpected axis")
      fatalError()
      // #endif
    }
  }

  var opposite: Axis.Set {
    if self == .horizontal {
      return .vertical
    } else if self == .vertical {
      return .horizontal
    } else {
      // #if Debug
//      NSObject.CrashAfterUserAlert("unexpected axis")
      fatalError()
      // #endif
    }
  }

  var isHorizontal: Bool { self == .horizontal }
  var isVertical: Bool { self == .vertical }
}


public extension Edge {
  var isHorizontal: Bool {
    switch self {
      case .bottom:
        return false
      case .top:
        return false
      case .trailing:
        return true
      case .leading:
        return true
    }
  }

  var isVertical: Bool { !isHorizontal }

  var axis: Axis.Set {
    switch self {
      case .bottom:
        return Axis.Set.vertical
      case .top:
        return Axis.Set.vertical
      case .trailing:
        return Axis.Set.horizontal
      case .leading:
        return Axis.Set.horizontal
    }
  }

  var set: Edge.Set {
    switch self {
      case .bottom:
        return Edge.Set.bottom
      case .trailing:
        return Edge.Set.trailing
      case .top:
        return Edge.Set.top
      case .leading:
        return Edge.Set.leading
    }
    // so odd that I can't figure out how to do this directly, need this 'var set' indirect solution
  }

  var opposite: Edge.Set {
    switch self {
      case .bottom:
        return Edge.Set.top
      case .trailing:
        return Edge.Set.leading
      case .top:
        return Edge.Set.bottom
      case .leading:
        return Edge.Set.trailing
    }
  }
}

public extension Axis.Set {
  var asTwoSidedEdge: Edge.Set {
    isVertical ? .vertical : .horizontal
  }

  var asDrawerEdge: Edge.Set {
    isVertical ? .bottom : .trailing
  }
}

//import AdAstraBridgingNSExtensions

public extension SwiftUI.UserInterfaceSizeClass {
  var isRegular: Bool { self == .regular }
  var isCompact: Bool { self == .compact }
}

public extension ToolbarItemPlacement {
  #if os(iOS)
  static var aaLeadingEdge: ToolbarItemPlacement { .navigationBarLeading }
  static var aaTrailingEdge: ToolbarItemPlacement { .navigationBarTrailing }
  #elseif os(macOS)
  static var aaLeadingEdge: ToolbarItemPlacement { .navigation }
  static var aaTrailingEdge: ToolbarItemPlacement { .primaryAction }
  #endif
}






