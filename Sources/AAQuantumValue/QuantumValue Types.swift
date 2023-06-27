//
//  File.swift
//
//
//  Created by Clint Ramirez Stephens  on 3/25/23.
//
import Foundation

// // MARK: - QuantumValue base types (most also expressible as literals)

extension QuantumValue:
  ExpressibleByStringLiteral,
  ExpressibleByFloatLiteral,
  ExpressibleByIntegerLiteral,
  ExpressibleByBooleanLiteral
{
  public init(stringLiteral value: Self.StringLiteralType) { self = QuantumValue.string(value) }
  public init(floatLiteral value: Double) { self = QuantumValue.double(value) }
  public init(integerLiteral value: Int) { self = QuantumValue.int(value) }
  public init(booleanLiteral value: Bool) { self = QuantumValue.bool(value) }

  public typealias FloatLiteralType = Double
  public typealias IntegerLiteralType = Int
  public typealias BooleanLiteralType = Bool
  public typealias StringLiteralType = String
}

public extension QuantumValue
// as-Type throwing access
{
  var asInt: Int { get throws {
    if case let .int(value) = self { return value }
    checkForIncorrectType()
    throw QuantumError.missingValue
  } }

  var asDouble: Double { get throws {
    if case let .double(value) = self { return value }
    checkForIncorrectType()
    throw QuantumError.missingValue
  } }

  var asString: String { get throws {
    if case let .string(value) = self { return value }
    checkForIncorrectType()
    throw QuantumError.missingValue
  } }

  var asBool: Bool { get throws {
    if case let .bool(value) = self { return value }
    checkForIncorrectType()
    throw QuantumError.missingValue
  } }

  var asData: Data { get throws {
    if case let .data(value) = self { return value }
    checkForIncorrectType()
    throw QuantumError.missingValue
  } }
}


extension Int: Quantumable {
  public var asQuantumValue: QuantumValue { QuantumValue(integerLiteral: self) }
  public init(_ qv: QuantumValue) throws { self = try qv.asInt }
}

extension Double: Quantumable {
  public var asQuantumValue: QuantumValue { QuantumValue(floatLiteral: self) }
  public init(_ qv: QuantumValue) throws { self = try qv.asDouble }
}

extension String: Quantumable {
  public var asQuantumValue: QuantumValue { QuantumValue(stringLiteral: self) }
  public init(_ qv: QuantumValue) throws { self = try qv.asString }
}

extension Bool: Quantumable {
  public var asQuantumValue: QuantumValue { QuantumValue(booleanLiteral: self) }
  public init(_ qv: QuantumValue) throws { self = try qv.asBool }
}

extension Data: Quantumable {
  public var asQuantumValue: QuantumValue { QuantumValue.data(self) }
  public init(_ qv: QuantumValue) throws { self = try qv.asData }
}



// MARK: - QuantumValue Extensions with Quantumable

/// all extensions work with an .asQuantumValue & an .init(QuantumValue). Only base types have asInt/asString/asData

extension JSONData: Quantumable {
  public var asQuantumValue: QuantumValue {
    QuantumValue.data(data)
  }

  public init(_ qv: QuantumValue) throws {
    self = try qv.asData.asJSON()
  }
}

extension UUID: Quantumable {
  public var asQuantumValue: QuantumValue { return QuantumValue.string(uuidString) }

  public init(_ qv: QuantumValue) throws {
    self = try UUID(uuidString: try qv.asString).ifNilThrow(AAErrorMessage.UnexpectedNil)
  }
}

