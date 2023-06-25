//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
import SwiftUI
// import UIKit
// import CoreData
// import SFSafeSymbols


open class BaseReadSizePreferenceKey: PreferenceKey {
	public static var defaultValue: CGSize = .zero
	public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


public extension View {
	func readSize(_ PKType: BaseReadSizePreferenceKey.Type, if condition: Bool = true, onChange: @escaping (CGSize) -> Void) -> some View {
    Group{
      if condition {
        background(
          GeometryReader { geometryProxy in
            Color.clear
              .preference(key: PKType, value: geometryProxy.size)
          }
        )
        .onPreferenceChange(PKType, perform: onChange)
      } else {
        background(
          Color.clear
        )
      }
    }
  }
  // func readSize(_ PKType: BaseReadSizePreferenceKey.Type, onChange: @escaping (CGSize) -> Void) -> some View {
  //   background(
  //     GeometryReader { geometryProxy in
  //       Color.clear
  //         .preference(key: PKType, value: geometryProxy.size)
  //     }
  //   )
  //   .onPreferenceChange(PKType, perform: onChange)
  // }
  // https://www.fivestars.blog/articles/swiftui-share-layout-information/
}




// 2022-03-20 - seems readSize() works but readGeometry() doesn't because it always tests same lhs==rhs values, not sure why.
// 2022-03-31 - it's because 'onChange' -- these functions don't call 'onChange' closureHandler until there is a change. But some places .'readGeometry' wants the values every time.

open class BaseReadGeometryPreferenceKey: PreferenceKey {
	public static var defaultValue: GeometryProxyContainer = GeometryProxyContainer(unique: true) // get the initial value to trigger an 'onChange' call
	public static func reduce(value: inout GeometryProxyContainer, nextValue: () -> GeometryProxyContainer) {}
}

public extension View {
	func readGeometryOnChange(_ PKType: BaseReadGeometryPreferenceKey.Type,
		in coordinateSpace: CoordinateSpace,
		onChange: @escaping (GeometryProxy) -> Void) -> some View {
			background(
				GeometryReader { geometryProxy in
					Color.clear
						.preference(key: PKType, value: GeometryProxyContainer(coordinateSpace: coordinateSpace, geometryProxy: geometryProxy))
				}
			)
			.onPreferenceChange(
				PKType,
				perform: { gpc in
					guard let geometryProxy = gpc.geometryProxy else {
//						CrashDuringDebug🛑("I don't expect this to happen ... maybe first preference read.")
            fatalError()
						return }
					onChange(geometryProxy)
				} )
		}

	func readGeometry(_ PKType: BaseReadGeometryPreferenceKey.Type,
		in coordinateSpace: CoordinateSpace,
		onUpdate: @escaping (GeometryProxy) -> Void) -> some View {
			background(
				GeometryReader { geometryProxy in
					Color.clear
						.preference(key: PKType, value:
													GeometryProxyContainer(unique: true, coordinateSpace: coordinateSpace, geometryProxy: geometryProxy))
				}
			)
			.onPreferenceChange(
				PKType,
				perform: { gpc in
					guard let geometryProxy = gpc.geometryProxy else {
//						CrashDuringDebug🛑("I don't expect this to happen ... maybe first preference read.")
            fatalError()
						return }
					onUpdate(geometryProxy)
				} )
		}

}

// struct ReadGeometryPreferenceKey: PreferenceKey {
// 	static var defaultValue: GeometryProxyContainer = GeometryProxyContainer()
// 	static func reduce(value: inout GeometryProxyContainer, nextValue: () -> GeometryProxyContainer) {}
// }

public struct GeometryProxyContainer: Equatable {
	var unique: Bool = false
	var coordinateSpace: CoordinateSpace? = nil
	var geometryProxy: GeometryProxy? = nil
	public static func == (lhs: GeometryProxyContainer, rhs: GeometryProxyContainer) -> Bool {
		if lhs.geometryProxy.isNil && rhs.geometryProxy.isNil {
      return true
    }
		guard let lgp = lhs.geometryProxy,
					let rgp = rhs.geometryProxy,
					let lcs = lhs.coordinateSpace,
					let rcs = rhs.coordinateSpace,
					lhs.coordinateSpace.isNotNil
		else {
      return false
    }

		guard lhs.unique.isOff && rhs.unique.isOff else { return false }

		return lgp.size == rgp.size &&
		lgp.frame(in: lcs) == rgp.frame(in: rcs)
	}
}
