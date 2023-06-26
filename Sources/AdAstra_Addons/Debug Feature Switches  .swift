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

// import OrderedCollections

import AdAstraBridgingNSExtensions

let trueDebug: Bool = true
let falseDebug: Bool = false

#if DEBUG
let trueDebugFalseRelease: Bool = true
let falseDebugTrueRelease: Bool = false
#else
let trueDebugFalseRelease: Bool = false
let falseDebugTrueRelease: Bool = true
#endif


public extension AdAstraDebugProtocol {

	// func allFeatures() -> OrderedDictionary<String, Any> {
	func allFeatures() -> Dictionary<String, Any> {

		var result = Dictionary<String, Any>()

		let mirror = Mirror(reflecting: self)

		for (property, value) in mirror.children {
			guard let property = property else { continue }
			// guard let feature = value as? Bool else { continue }
			// result[property] = feature
			result[property] = value as Any
		}

		return result
	}

	func update(_ feature: String, to newValue: Any){
		let mirror = Mirror(reflecting: self)

		for (property, var _) in mirror.children {
			// let (property, value) = childTuple
			guard let property = property else { continue }
			if property == feature {
				self.setValue(newValue, forKey: feature)
				// value = newValue
				return
			}
		}
	}

	subscript(key: String) -> Any {
		let features = allFeatures()
    return features[key] as Any
	}

}

public protocol AdAstraDebugProtocol: NSObject, ObservableObject {
  static var feature: Self { get set }
  // public static let e = true // enabled
}

public struct FeaturesListingView_Toggle<D: AdAstraDebugProtocol>: View, Identifiable {
  @ObservedObject var debugClass: D
	@State var key: String
	@State var localValue: Bool

  public init( debugClass: D, key: String ){
    self.debugClass = debugClass
		_key = State(initialValue: key)
		_localValue = State(initialValue:
													D.feature.allFeatures()[key] as! Bool )
	}

	@State public var id: UUID = UUID()

	// var isOn: Binding<Bool> {
	// 	let binding: Binding<Bool> = Binding<Bool>(
	// 		get: {
	// 			// value
	// 			// AdAstraDebug.feature_?
	// 			// AdAstraDebug.feature.allFeatures()[key]
	// 			// AdAstraDebug.feature_?.allFeatures()[key] as! Bool
 //
	// 			localValue
	// 		},
	// 		set: {
	// 			// update2.toggle()
	// 			//id = UUID()
	// 			localValue = $0
	// 			update.toggle()
	// 		}
	// 	)
	// 	return binding
	// }

	public var body: some View {
		Toggle(isOn: $localValue) {
			Label("\(key)", systemImage: "gearshape.fill")
		}
		.onChange(of: localValue){ newValue in
			debugClass.update(key, to: newValue)
		}
	}
}


public struct FeaturesListingView_Stepper<D: AdAstraDebugProtocol>: View {
  @ObservedObject var debugClass: D
	@State var key: String
	@State var value: Int
	public init(
    debugClass: D,
		key: String,
		value: Int){
      self.debugClass = debugClass
			_key = State(initialValue: key)
			_value = State(initialValue: value)
		}

	public var body: some View {
		Stepper(key + " - " + value.description,
				onIncrement: { debugClass.update(key, to: value + 1) },
				onDecrement: { debugClass.update(key, to: value - 1 ) }
		)
	}
}


struct DebugFeatureOnScreenDisplay: View {
  static var Value: Int = 0
  var body: some View {
    Color.clear
      .overlay(alignment: .bottomTrailing){
          
        ZStack {
          Capsule(style: .continuous)
						.background( Color.aaSystemGroupedBackground )
          
          HStack{
            Text("UINSTokenizedTextView Alignment").lineLimit(3)
            Stepper( Self.Value.description,
                     onIncrement: { Self.Value += 1 },
                     onDecrement: { Self.Value -= 1 })
          }
          
        }
        
      }
    // VStack{
      
    // }
  }
}
