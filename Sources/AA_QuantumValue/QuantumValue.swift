// //
// //  File 2.swift
// //
// //
// // Created by cms on 1/16/22.
// //
//
// import Foundation
//
//
//
// public enum QuantumValue: JSONCodable, Equatable {
//   case int(Int)
//   case double(Double)
//   case string(String)
//   // case date(Date?)
//   case bool(Bool)
//   // case uuid(UUID?)
//   case data(Data)
//   // case json(JSONData?)
//   // case array([QuantumValue]?)
//   // case dictionary(Dictionary<QuantumValue,QuantumValue>)
//
//   public init(from decoder: Decoder) throws {
//     if false { }
//     else if let int = try? decoder.singleValueContainer().decode(Int.self) { self = .int(int) }
//     else if let v = try? decoder.singleValueContainer().decode(Double.self) { self = .double(v) }
//     else if let v = try? decoder.singleValueContainer().decode(String.self) { self = .string(v) }
//     // else if let v = try? decoder.singleValueContainer().decode(Date.self) { self = .date(v) }
//     else if let v = try? decoder.singleValueContainer().decode(Bool.self) { self = .bool(v) }
//     // else if let v = try? decoder.singleValueContainer().decode(UUID.self) { self = .uuid(v) }
//     else if let v = try? decoder.singleValueContainer().decode(Data.self) { self = .data(v) }
//     // else if let v = try? decoder.singleValueContainer().decode(JSONData.self) { self = .json(v) }
//     // else if let v = try? decoder.singleValueContainer().decode([QuantumValue].self) { self = .array(v) }
//     // else if let v = try? decoder.singleValueContainer().decode(Dictionary<QuantumValue,QuantumValue>.self) { self = .dictionary(v) }
//
//     throw QuantumError.missingValue
//   }
//
//   //
//   // public init(_ newValue: Quantumable) throws {
//   //   // if false { fatalError()
//   //   // } else if let v = newValue as? Int? { self = .int(v)
//   //   // } else if let v = newValue as? Double? { self = .double(v)
//   //   // } else if let v = newValue as? String? { self = .string(v)
//   //   // // } else if let v = newValue as? Date? { self = .date(v)
//   //   // } else if let v = newValue as? Bool? { self = .bool(v)
//   //   // // } else if let v = newValue as? UUID? { self = .uuid(v)
//   //   // } else if let v = newValue as? Data? { self = .data(v)
//   //   // } else if let v = newValue as? JSONData? { self = .json(v)
//   //   // } else if let v = newValue as? [Quantumable]? {
//   //   //   // self = .array(v?.map{QuantumValue($0)})
//   //   //   // } else if let v = newValue as? Dictionary<QuantumValue,QuantumValue> { self = .dictionary(v); return
//   //   // } else {
//   //   //   CrashDuringDebug🛑("QuantumValue failed to unwrap newValue")
//   //   //   fatalError()
//   //   // }
//   //
//   //   self = try newValue.asQuantumValue
//   // }
//
//
//   public init?(asPossible newValue: QuantumablePossible) throws {
//     guard let qv = try newValue.asQuantumValuePossible else { return nil }
//     self = qv
//   }
//
//   public init(asGuarenteed newValue: QuantumableGuarenteed) {
//     self = newValue.asQuantumValueGuarenteed
//   }
//
//   public init(_ newValue: QuantumableGuarenteed) {
//     self = newValue.asQuantumValueGuarenteed
//   }
//
//   public init?(asOptional newValue: QuantumableOptional?) {
//     guard let qv = newValue?.asQuantumValueOptional else {
//       return nil
//     }
//     self = qv
//   }
//
//   public init(asThrowing newValue: QuantumableThrowing) throws {
//     self = try newValue.asQuantumValueThrowing
//   }
//
//
//   // public init(_ newValue: Codable?) {
//   //   if let newValue = newValue {
//   //     self.init(newValue)
//   //   } else {
//   //     return nil
//   //   }
//   // }
//
//   public var codableValue: Codable {
//     switch self {
//       case let .int(int): return int
//       case let .double(double): return double
//       case let .string(string): return string
//       // case let .date(date): return date
//       case let .bool(bool): return bool
//       // case let .uuid(uuid): return uuid
//       case let .data(data): return data
//         // case let .json(json): return json
//         // case let .array(array): return array
//         // case .dictionary(let dictionary):
//         // return dictionary
//     }
//   }
//
//   internal enum QuantumError: Error {
//     case missingValue
//   }
//
//   static var MissingValue: QuantumValue {
//     // QuantumValue.uuid(UUID.zero)
//     .MissingValue
//   }
//
//   static var MissingValueAsserting: QuantumValue {
//     assertionFailure()
//     // return QuantumValue.uuid(UUID.zero)
//     return MissingValue
//   }
//   // https://stackoverflow.com/questions/48297263/how-to-use-any-in-codable-type
// }
//
// public extension QuantumValue { // representing true/false
//   var representingTrueOrFalse: Bool? {
//     Self.RepresentingTrueOrFalse(self)
//   }
//
//   static func RepresentingTrueOrFalse(_ value: QuantumValue) -> Bool? {
//     switch value {
//       case let .int(int):
//         return int != .zero
//       case let .double(double):
//         return double != .zero
//       case let .string(string):
//         // guard let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return nil }
//         let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() // else { return nil }
//         if trimmedString == "true" || trimmedString == "t" {
//           return true
//         }
//         if trimmedString == "false" || trimmedString == "f" {
//           return false
//         }
//         if let dbl = Double(trimmedString) {
//           return Self.RepresentingTrueOrFalse(dbl.asQuantumValueGuarenteed)
//         }
//         return nil
//       // case let .date(_):
//       case let .bool(bool):
//         return bool
//       // case let .uuid(_):
//       // case let .data(data):
//       /*
//        case let .json(json):
//
//        if let newValue: Quantumable = (data.jsonMaybeTo(Int.self) ??
//          data.asJSON?.jsonMaybeTo(Double.self) ??
//          data.asJSON?.jsonMaybeTo(String.self) ??
//          data.asJSON?.jsonMaybeTo(Bool.self)
//        ) {
//          return Self.RepresentingTrueOrFalse(newValue.asQuantumValue)
//        }
//        if let newValue = json?.jsonMaybeTo(QuantumValue.self) {
//          return Self.RepresentingTrueOrFalse(newValue)
//        }
//        return nil
//        */
//       // case let .array(array):
//       // case .dictionary(let dictionary):
//       default:
//         return nil
//     }
//   }
// } // representing true/false
//
// public extension QuantumValue { // by-type optional access
//   var asInt: Int? {
//     if case let .int(value) = self { return value }
//     checkForIncorrectType()
//     return nil
//   }
//
//   var asDouble: Double? {
//     if case let .double(value) = self { return value }
//     checkForIncorrectType()
//     return nil
//   }
//
//   var asString: String? {
//     if case let .string(value) = self { return value }
//     checkForIncorrectType()
//     return nil
//   }
//
//   // var asDate: Date? {
//   //   if case let .date(value) = self { return value }
//   //   checkForIncorrectType()
//   //   return nil
//   // }
//
//   var asBool: Bool? {
//     if case let .bool(value) = self { return value }
//     checkForIncorrectType()
//     return nil
//   }
//
//   // var asUUID: UUID? {
//   //   if case let .uuid(value) = self { return value }
//   //   checkForIncorrectType()
//   //   return nil
//   // }
//
//   var asData: Data? {
//     if case let .data(value) = self { return value }
//     checkForIncorrectType()
//     return nil
//   }
//
//   // var asJSONData: JSONData? {
//   //   if case let .json(value) = self { return value }
//   //   checkForIncorrectType()
//   //   return nil
//   // }
//
//   // var asArray: [Codable]? {
//   //   if case let .array(value) = self { return value }
//   //   checkForIncorrectType()
//   //   return nil
//   // }
//
//   // public var asDictionary: Dictionary<QuantumValue,QuantumValue>? {
//   // if case .dictionary(let value) = self { return value }
//   // checkForIncorrectType()
//   // return nil
//   // }
// } // by-type optional access
//
// public extension QuantumValue { // typedValue() access
//   func typedValue() -> Int? { asInt }
//   func typedValue() -> Double? { asDouble }
//   func typedValue() -> String? { asString }
//   // func typedValue() -> Date? { asDate }
//   func typedValue() -> Bool? { asBool }
//   // func typedValue() -> UUID? { asUUID }
//   func typedValue() -> Data? { asData }
//   // func typedValue() -> JSONData? { asJSONData }
//   // public func typedValue() -> [QuantumValue] { asArray }
//   // func typedValue() -> [Codable]? { asArray }
//
//   func typedValue() throws -> Int { try asInt.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Int")) }
//   func typedValue() throws -> Double { try asDouble.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Double")) }
//   func typedValue() throws -> String { try asString.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable String")) }
//   // func typedValue() throws -> Date { try asDate.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Date")) }
//   func typedValue() throws -> Bool { try asBool.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Bool")) }
//   // func typedValue() throws -> UUID { try asUUID.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable UUID")) }
//   func typedValue() throws -> Data { try asData.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Data")) }
//   // func typedValue() throws -> JSONData { try asJSONData.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable JSONData")) }
//   // public func typedValue() throws -> [QuantumValue] { try asArray.ifNilThrow( AAErrorMessage("Unexpected value unavailable","QuantumValue unavailable QuantumValue")) }
//   // func typedValue() throws -> [Codable] { try asArray.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Codable")) }
//
//   func typedValueUnsafelyUnwrapped() -> Int { asInt! }
//   func typedValueUnsafelyUnwrapped() -> Double { asDouble! }
//   func typedValueUnsafelyUnwrapped() -> String { asString! }
//   // func typedValueUnsafelyUnwrapped() -> Date { asDate! }
//   func typedValueUnsafelyUnwrapped() -> Bool { asBool! }
//   // func typedValueUnsafelyUnwrapped() -> UUID { asUUID! }
//   func typedValueUnsafelyUnwrapped() -> Data { asData! }
//   // func typedValueUnsafelyUnwrapped() -> JSONData { asJSONData! }
//   // public func typedValueUnsafelyUnwrapped() -> [QuantumValue] { asArray! }
//   // func typedValueUnsafelyUnwrapped() -> [Codable] { asArray! }
// } // typedValue() access
//
// extension QuantumValue:
//   ExpressibleByStringLiteral,
//   ExpressibleByFloatLiteral,
//   ExpressibleByIntegerLiteral,
//   ExpressibleByBooleanLiteral
// {
//   public init(stringLiteral value: Self.StringLiteralType) {
//     self = QuantumValue(asGuarenteed: value)
//   }
//
//   public init(floatLiteral value: Double) {
//     self = QuantumValue(asGuarenteed: value)
//   }
//
//   public init(integerLiteral value: Int) {
//     self = QuantumValue(asGuarenteed: value)
//   }
//
//   public init(booleanLiteral value: Bool) {
//     self = QuantumValue(asGuarenteed: value)
//   }
//
//
//   public typealias FloatLiteralType = Double
//   public typealias IntegerLiteralType = Int
//   public typealias BooleanLiteralType = Bool
//   public typealias StringLiteralType = String
// }
//
//
// public protocol Quantumable: QuantumableGuarenteed { }
//
// public protocol QuantumablePossible {
//   var asQuantumValuePossible: QuantumValue? { get throws }
// }
//
// public protocol QuantumableGuarenteed {
//   var asQuantumValueGuarenteed: QuantumValue { get }
// }; extension QuantumableGuarenteed {
//   public var asQuantumValuePossible: QuantumValue? { get throws {
//     asQuantumValueGuarenteed
//   }}
// }
//
// public protocol QuantumableOptional: Quantumable {
//   var asQuantumValueOptional: QuantumValue? { get }
// }
//
// public protocol QuantumableThrowing: Quantumable {
//   var asQuantumValueThrowing: QuantumValue { get throws }
// }
//
//
//
// public extension Quantumable { }
//
//
//
// extension Int: QuantumableGuarenteed {
//   public var asQuantumValueGuarenteed: QuantumValue { QuantumValue(integerLiteral: self) } }
//
// extension Double: QuantumableGuarenteed { public var asQuantumValueGuarenteed: QuantumValue { QuantumValue(floatLiteral: self) } }
// extension String: QuantumableGuarenteed { public var asQuantumValueGuarenteed: QuantumValue { QuantumValue(stringLiteral: self) } }
// // extension Date: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }  }
// extension Bool: QuantumableGuarenteed { public var asQuantumValueGuarenteed: QuantumValue { QuantumValue(booleanLiteral: self) } }
// // extension UUID: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }  }
// // extension Data: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(self) }  }
// // extension JSONData: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }  }
// // extension Array: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }  }
// // extension QuantumValue: Quantumable { public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }  }
//
// extension Data: QuantumableGuarenteed {
//   public var asQuantumValueGuarenteed: QuantumValue {
//     QuantumValue.data(self)
//   }
// }
//
// extension JSONData: QuantumableGuarenteed {
//   public var asQuantumValueGuarenteed: QuantumValue {
//     QuantumValue(asGuarenteed: data)
//   }
//
//   public init?(from qv: QuantumValue) {
//     if let unwrapped = qv.asData?.asJSON {
//       self = unwrapped
//     }
//     return nil
//   }
// }
//
// extension UUID: QuantumableGuarenteed {
//   public var asQuantumValueGuarenteed: QuantumValue {
//     guard let data = try? asJSON.data else { return .MissingValue}
//     return QuantumValue(asGuarenteed: data)
//   }
// }
//
//
// #if DEBUG
// #endif
// extension QuantumValue { // Debugging check for incorrect type
//   static var qvCheckInProgress: Bool = false
//   func checkForIncorrectType() {
//     #if DEBUG
//     if Self.qvCheckInProgress{ return }
//     Self.qvCheckInProgress = true
//     if false {
//     } else if asInt.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asInt has the value")
//     } else if asDouble.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDouble has the value")
//     } else if asString.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asString has the value")
//       // } else if asDate.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDate has the value")
//     } else if asBool.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asBool has the value")
//       // } else if asUUID.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asUUID has the value")
//     } else if asData.isNotNil {
//       CrashDuringDebug🛑("QuantumValue accessed wrong case, .asData has the value")
//       // } else if asJSONData.isNotNil {
//       //   CrashDuringDebug🛑("QuantumValue accessed wrong case, .json has the value")
//       // } else if asArray.isNotNil {
//       // CrashDuringDebug🛑("QuantumValue accessed wrong case, .asArray has the value")
//       // } else if asDictionary.isNotNil {
//       // CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDictionary has the value")
//     }
//     #endif
//   }
// }
