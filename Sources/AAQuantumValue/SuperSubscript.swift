//
//  File 2.swift
//
//
//  Created by Clint Ramirez Stephens  on 3/5/23.
//

import Foundation


public extension QuantumValue { // typedValue() access
  func typedValue() -> Int? { try? asInt }
  func typedValue() -> Double? { try? asDouble }
  func typedValue() -> String? { try? asString }
  // func typedValue() -> Date? { asDate }
  func typedValue() -> Bool? { try? asBool }
  // func typedValue() -> UUID? { asUUID }
  func typedValue() -> Data? { try? asData }
  // func typedValue() -> JSONData? { asJSONData }
  // public func typedValue() -> [QuantumValue] { asArray }
  // func typedValue() -> [Codable]? { asArray }

  func typedValue() throws -> Int { try asInt } // .ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Int")) }
  func typedValue() throws -> Double { try asDouble } // .ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Double")) }
  func typedValue() throws -> String { try asString } // .ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable String")) }
  // func typedValue() throws -> Date { try asDate.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Date")) }
  func typedValue() throws -> Bool { try asBool } // .ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Bool")) }
  // func typedValue() throws -> UUID { try asUUID.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable UUID")) }
  func typedValue() throws -> Data { try asData } // .ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Data")) }
  // func typedValue() throws -> JSONData { try asJSONData.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable JSONData")) }
  // public func typedValue() throws -> [QuantumValue] { try asArray.ifNilThrow( AAErrorMessage("Unexpected value unavailable","QuantumValue unavailable QuantumValue")) }
  // func typedValue() throws -> [Codable] { try asArray.ifNilThrow(AAErrorMessage("Unexpected value unavailable", "QuantumValue unavailable Codable")) }


  func typedValueUnsafelyUnwrapped() -> Int { try! asInt }
  func typedValueUnsafelyUnwrapped() -> Double { try! asDouble }
  func typedValueUnsafelyUnwrapped() -> String { try! asString }
  // func typedValueUnsafelyUnwrapped() -> Date { asDate! }
  func typedValueUnsafelyUnwrapped() -> Bool { try! asBool }
  // func typedValueUnsafelyUnwrapped() -> UUID { asUUID! }
  func typedValueUnsafelyUnwrapped() -> Data { try! asData }
  // func typedValueUnsafelyUnwrapped() -> JSONData { asJSONData! }
  // public func typedValueUnsafelyUnwrapped() -> [QuantumValue] { asArray! }
  // func typedValueUnsafelyUnwrapped() -> [Codable] { asArray! }
} // typedValue() access

public extension Quantumable {
  var asQuantumValueGuarenteed: QuantumValue {
    return (try? asQuantumValue) ?? .MissingValueAsserting
  }
}

/// NoDefault -- must provide value to quantumKey, nil unaccepted
/// NonOptionalResult -- will always be some result, never nil
public protocol QuantumVender_NoDefault_NonOptionalResult {
  associatedtype QuantumKey: Hashable, JSONCodable
  typealias ProductKey = QuantumKey
  subscript(quantumKey _: ProductKey) -> QuantumValue { get set }

}; public extension QuantumVender_NoDefault_NonOptionalResult {
  // subscript(_ product: Products?) -> QuantumValue { get {
  //   self[withDefault: product]
  // } set {
  //   self[withDefault: product] = newValue
  // } }


  private subscript(sansDefault product: ProductKey) -> QuantumValue { get{
    self[quantumKey: product]
  } set{
    self[quantumKey: product] = newValue
  } }

  subscript(qvu product: ProductKey) -> Int { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }
  subscript(qvu product: ProductKey) -> Double { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }
  subscript(qvu product: ProductKey) -> String { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey) -> Date { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValue } }
  subscript(qvu product: ProductKey) -> Bool { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey) -> UUID { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValue } }
  subscript(qvu product: ProductKey) -> Data { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey) -> JSONData { get { self[sansDefault: product].typedValueUnsafelyUnwrapped() } set { self[sansDefault: product] = newValue.asQuantumValueGuarenteed } }

  subscript(qv product: ProductKey) -> Int { get throws { try self[sansDefault: product].typedValue() } }
  subscript(qv product: ProductKey) -> Double { get throws { try self[sansDefault: product].typedValue() } }
  subscript(qv product: ProductKey) -> String { get throws { try self[sansDefault: product].typedValue() } }
  // subscript(qv product: ProductKey) -> Date { get throws { try self[sansDefault: product].typedValue() } }
  subscript(qv product: ProductKey) -> Bool { get throws { try self[sansDefault: product].typedValue() } }
  // subscript(qv product: ProductKey) -> UUID { get throws { try self[sansDefault: product].typedValue() } }
  subscript(qv product: ProductKey) -> Data { get throws { try self[sansDefault: product].typedValue() } }
  // subscript(qv product: ProductKey) -> JSONData { get throws { try self[sansDefault: product].typedValue() } }


  // func qv(_ product: ProductKey) -> Int { self[qv: product] }
  // func qv(_ product: ProductKey) -> Double { self[qv: product] }
  // func qv(_ product: ProductKey) -> String { self[qv: product] }
  // func qv(_ product: ProductKey) -> Date { self[qv: product] }
  // func qv(_ product: ProductKey) -> Bool { self[qv: product] }
  // func qv(_ product: ProductKey) -> UUID { self[qv: product] }
  // func qv(_ product: ProductKey) -> Data { self[qv: product] }
  // func qv(_ product: ProductKey) -> JSONData { self[qv: product] }
}

/// NoDefault -- must provide value to quantumKey, nil unaccepted
/// NonOptionalResult -- will always be some result, never nil
/// Throwable
public protocol QuantumVender_NoDefault_NonOptionalResult_Throwable {
  associatedtype QuantumKey: Hashable, JSONCodable
  typealias ProductKey = QuantumKey
  subscript(quantumKey _: ProductKey) -> QuantumValue { get throws }
  subscript(setQuantumKey _: ProductKey) -> QuantumValue { get set }

}; public extension QuantumVender_NoDefault_NonOptionalResult_Throwable {
  // subscript(_ product: Products?) -> QuantumValue { get {
  //   self[withDefault: product]
  // } set {
  //   self[withDefault: product] = newValue
  // } }


  private subscript(sansDefaultThrowable product: ProductKey) -> QuantumValue { get throws {
    try self[quantumKey: product]
  } }
  private subscript(setSansDefaultThrowable product: ProductKey) -> QuantumValue { get{ fatalError() } set{
    self[setQuantumKey: product] = newValue
  } }

  subscript(qv product: ProductKey) -> Int { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  subscript(qv product: ProductKey) -> Double { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  subscript(qv product: ProductKey) -> String { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  // subscript(qv product: ProductKey) -> Date { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  subscript(qv product: ProductKey) -> Bool { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  // subscript(qv product: ProductKey) -> UUID { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  subscript(qv product: ProductKey) -> Data { get throws { try self[sansDefaultThrowable: product].typedValue() } }
  // subscript(qv product: ProductKey) -> JSONData { get throws { try self[sansDefaultThrowable: product].typedValue() } }
}


public protocol QuantumVender_WithDefault_NonOptionalResult {
  associatedtype QuantumKey: Hashable, JSONCodable
  typealias ProductKey = QuantumKey
  // subscript(_: ProductKey) -> QuantumValue? { get set }
  // subscript(wdnr: ProductKey) -> QuantumValue? { get set }
  // subscript(_: ProductKey) -> QuantumValue? { get set }
  subscript(quantumKey _: ProductKey?) -> QuantumValue { get set }

}; public extension QuantumVender_WithDefault_NonOptionalResult {
  private subscript(withDefault withDefault: ProductKey?) -> QuantumValue { get{
    self[quantumKey: withDefault]
  } set{
    self[quantumKey: withDefault] = newValue
  } }

  subscript(qvu product: ProductKey? = nil) -> Int { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValueGuarenteed } }
  subscript(qvu product: ProductKey? = nil) -> Double { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValueGuarenteed } }
  subscript(qvu product: ProductKey? = nil) -> String { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey? = nil) -> Date { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValue } }
  subscript(qvu product: ProductKey? = nil) -> Bool { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey? = nil) -> UUID { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValue } }
  subscript(qvu product: ProductKey? = nil) -> Data { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValueGuarenteed } }
  // subscript(qvu product: ProductKey? = nil) -> JSONData { get { self[withDefault: product].typedValueUnsafelyUnwrapped() } set { self[withDefault: product] = newValue.asQuantumValue } }



  subscript(qv product: ProductKey? = nil) -> Int { get throws { try self[withDefault: product].typedValue() } }
  subscript(qv product: ProductKey? = nil) -> Double { get throws { try self[withDefault: product].typedValue() } }
  subscript(qv product: ProductKey? = nil) -> String { get throws { try self[withDefault: product].typedValue() } }
  // subscript(qv product: ProductKey? = nil) -> Date { get throws { try self[withDefault: product].typedValue() } }
  subscript(qv product: ProductKey? = nil) -> Bool { get throws { try self[withDefault: product].typedValue() } }
  // subscript(qv product: ProductKey? = nil) -> UUID { get throws { try self[withDefault: product].typedValue() } }
  subscript(qv product: ProductKey? = nil) -> Data { get throws { try self[withDefault: product].typedValue() } }
  // subscript(qv product: ProductKey? = nil) -> JSONData { get throws { try self[withDefault: product].typedValue() } }



  // func qv(_ product: ProductKey?) -> Int { self[qv: product] }
  // func qv(_ product: ProductKey?) -> Double { self[qv: product] }
  // func qv(_ product: ProductKey?) -> String { self[qv: product] }
  // func qv(_ product: ProductKey?) -> Date { self[qv: product] }
  // func qv(_ product: ProductKey?) -> Bool { self[qv: product] }
  // func qv(_ product: ProductKey?) -> UUID { self[qv: product] }
  // func qv(_ product: ProductKey?) -> Data { self[qv: product] }
  // func qv(_ product: ProductKey?) -> JSONData { self[qv: product] }
}




















public protocol QuantumVender_NoDefault_OptionalResult {
  associatedtype QuantumKey: Hashable, JSONCodable
  typealias ProductKey = QuantumKey
//  subscript(quantumKey _: ProductKey) -> QuantumValue? { get set }
  subscript(_: ProductKey) -> QuantumValue? { get set }

}; public extension QuantumVender_NoDefault_OptionalResult {
  private subscript(optResult product: ProductKey) -> QuantumValue? { get{
//    self[quantumKey: product]
    self[product]
  } set{
//    self[quantumKey: product] = newValue
    self[product] = newValue
  } }


  subscript(qv product: ProductKey) -> Int? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValueGuarenteed } }
  subscript(qv product: ProductKey) -> Double? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValueGuarenteed } }
  subscript(qv product: ProductKey) -> String? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValueGuarenteed } }
  // subscript(qv product: ProductKey) -> Date? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  subscript(qv product: ProductKey) -> Bool? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValueGuarenteed } }
  // subscript(qv product: ProductKey) -> UUID? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  subscript(qv product: ProductKey) -> Data? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValueGuarenteed } }
  // subscript(qv product: ProductKey) -> JSONData? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }


  func qv(_ product: ProductKey) -> Int? { self[qv: product] }
  func qv(_ product: ProductKey) -> Double? { self[qv: product] }
  func qv(_ product: ProductKey) -> String? { self[qv: product] }
  // func qv(_ product: ProductKey) -> Date? { self[qv: product] }
  func qv(_ product: ProductKey) -> Bool? { self[qv: product] }
  // func qv(_ product: ProductKey) -> UUID? { self[qv: product] }
  func qv(_ product: ProductKey) -> Data? { self[qv: product] }
  // func qv(_ product: ProductKey) -> JSONData? { self[qv: product] }
}




public protocol QuantumVender_WithDefault_OptionalResult {
  associatedtype QuantumKey: Hashable, JSONCodable
  typealias ProductKey = QuantumKey
  // subscript(_: ProductKey?) -> QuantumValue? { get set }
  // subscript(wdor: ProductKey?) -> QuantumValue? { get set }
  subscript(quantumKey _: ProductKey?) -> QuantumValue? { get set }
  // subscript(quantumKey2: ProductKey?) -> QuantumValue? { get set }

}; public extension QuantumVender_WithDefault_OptionalResult {
  private subscript(optResult product: ProductKey?) -> QuantumValue? { get{
    self[quantumKey: product]
  } set{
    self[quantumKey: product] = newValue
  } }


//  subscript(qv product: ProductKey? = nil) -> Int? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue } }
  subscript(qv product: ProductKey? = nil) -> Int? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }

  subscript(qv product: ProductKey? = nil) -> Double? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  subscript(qv product: ProductKey? = nil) -> String? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  // subscript(qv product: ProductKey? = nil) -> Date? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  subscript(qv product: ProductKey? = nil) -> Bool? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  // subscript(qv product: ProductKey? = nil) -> UUID? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  subscript(qv product: ProductKey? = nil) -> Data? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }
  // subscript(qv product: ProductKey? = nil) -> JSONData? { get { self[optResult: product]?.typedValue() } set { self[optResult: product] = newValue?.asQuantumValue } }


  func qv(_ product: ProductKey?) -> Int? { self[qv: product] }
  func qv(_ product: ProductKey?) -> Double? { self[qv: product] }
  func qv(_ product: ProductKey?) -> String? { self[qv: product] }
  // func qv(_ product: ProductKey?) -> Date? { self[qv: product] }
  func qv(_ product: ProductKey?) -> Bool? { self[qv: product] }
  // func qv(_ product: ProductKey?) -> UUID? { self[qv: product] }
  func qv(_ product: ProductKey?) -> Data? { self[qv: product] }
  // func qv(_ product: ProductKey?) -> JSONData? { self[qv: product] }
}
