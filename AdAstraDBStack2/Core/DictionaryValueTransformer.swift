// //
// //  File.swift
// //  
// //
// //  Created by cms on 1/15/22.
// //
// 
// import Foundation
// 
// @objc(NSDictionaryValueTransformer)
// public final class NSDictionaryValueTransformer: ValueTransformer {
// 
// 	override public func transformedValue(_ value: Any?) -> Any? {
// 		guard let dictionary = value as? NSDictionary else { return nil }
// 
// 		do {
// 			return try NSKeyedArchiver.archivedData(withRootObject: dictionary, requiringSecureCoding: true)
// 		} catch {
// 			assertionFailure("Failed to transform a `NSDictionary` to a archive format")
// 			return nil
// 		}
// 	}
// 
// 	override public func reverseTransformedValue(_ value: Any?) -> Any? {
// 		do {
// 			guard let data = value as? NSData,
// 						!data.isEmpty,
// 						let dictionary = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data as Data) else { return nil }
// 			return dictionary
// 		} catch {
// 			assertionFailure("Failed to transform `Data` to `NSDictionary`")
// 			return nil
// 		}
// 	}
// 
// 	override public class func transformedValueClass() -> AnyClass {
// 		return NSDictionary.self
// 	}
// 
// 	override public class func allowsReverseTransformation() -> Bool {
// 		return true
// 	}
// 	// }
// 
// 	// extension DictionaryValueTransformer {
// 
// 	/// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
// 	static let name = NSValueTransformerName(rawValue: String(describing: NSDictionaryValueTransformer.self))
// 
// 	/// Registers the value transformer with `ValueTransformer`.
// 	public static func register() {
// 		let transformer = NSDictionaryValueTransformer()
// 		ValueTransformer.setValueTransformer(transformer, forName: name)
// 	}
// 
// 	// https://www.avanderlee.com/swift/valuetransformer-core-data/
// }
