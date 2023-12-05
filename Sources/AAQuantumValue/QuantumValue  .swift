//
//  File 2.swift
//
//
// Created by cms on 1/16/22.
//

import Foundation
@_exported import AdAstraExtensions
@_exported import AALogger


public protocol Quantumable {
  // JSON handling uses try/throw/catch, so not expecting 'asQuantumValue' to always suceed without throwing an error
  var asQuantumValue: QuantumValue { get throws }
  init(_: QuantumValue) throws
}; extension Quantumable { }

// #if Disabled
public extension Quantumable where Self: JSONCodable {
  init(_ qv: QuantumValue) throws {
    // self = try qv.to(JSONData.self).jsonTo(Self.self)
    self = try qv.asData.jsonTo(Self.self)
  }

  var asQuantumValue: QuantumValue { get throws {
    try asJSON.asQuantumValue
  } }
}
// #endif

public enum QuantumValue: JSONCodable, Equatable, Hashable {
  case int(Int)
  case double(Double)
  case string(String)
  // case date(Date)
  case bool(Bool)
  // case uuid(UUID)
  case data(Data)
  // case json(JSONData)
  // case array([QuantumValue])
  // case dictionary(Dictionary<QuantumValue,QuantumValue>)

	#if Disabled
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		if false { }
		else if case let .int(value) = self {
			try container.encode(value) }
		else if case let .double(value) = self {
			try container.encode(value) }
		else if case let .string(value) = self {
			try container.encode(value) }
		else if case let .bool(value) = self {
			try container.encode(value) }
		else if case let .data(value) = self {
			try container.encode(value) }
//		else { }
		
	}
	public init(from decoder: Decoder) throws {
//		self.init(<#T##newValue: Quantumable##Quantumable#>)

		if false { throw QuantumError.missingValue }
		else if let v = try? decoder.singleValueContainer().decode(String.self) {
			self.init(stringLiteral: v) }
		else if let v = try? decoder.singleValueContainer().decode(Double.self) {
			self.init(floatLiteral: v) }
		else if let v = try? decoder.singleValueContainer().decode(Int.self) {
			self.init(integerLiteral: v) }
		// else if let v = try? decoder.singleValueContainer().decode(Date.self) { self = .date(v) }
		else if let v = try? decoder.singleValueContainer().decode(Bool.self) {
			self.init(booleanLiteral: v) }
		// else if let v = try? decoder.singleValueContainer().decode(UUID.self) { self = .uuid(v) }
		else if let v = try? decoder.singleValueContainer().decode(Data.self) {
			self.init(dataLiteral: v)}
		// else if let v = try? decoder.singleValueContainer().decode(JSONData.self) { self = .json(v) }
		// else if let v = try? decoder.singleValueContainer().decode([QuantumValue].self) { self = .array(v) }
		// else if let v = try? decoder.singleValueContainer().decode(Dictionary<QuantumValue,QuantumValue>.self) { self = .dictionary(v) }
		else { throw QuantumError.missingValue }
	}
	#endif

  public init(_ newValue: Quantumable) throws {
    // if false { fatalError()
    // } else if let v = newValue as? Int? { self = .int(v)
    // } else if let v = newValue as? Double? { self = .double(v)
    // } else if let v = newValue as? String? { self = .string(v)
    // // } else if let v = newValue as? Date? { self = .date(v)
    // } else if let v = newValue as? Bool? { self = .bool(v)
    // // } else if let v = newValue as? UUID? { self = .uuid(v)
    // } else if let v = newValue as? Data? { self = .data(v)
    // } else if let v = newValue as? JSONData? { self = .json(v)
    // } else if let v = newValue as? [Quantumable]? {
    //   // self = .array(v?.map{QuantumValue($0)})
    //   // } else if let v = newValue as? Dictionary<QuantumValue,QuantumValue> { self = .dictionary(v); return
    // } else {
    //   CrashDuringDebug🛑("QuantumValue failed to unwrap newValue")
    //   fatalError()
    // }
    
    self = try newValue.asQuantumValue
  }
  
  
  public func to<Q: Quantumable>(_ q: Q.Type) throws -> Q {
    try q.init(self)
  }
  
  /*
   public init?(asPossible newValue: QuantumablePossible) throws {
   guard let qv = try newValue.asQuantumValuePossible else { return nil }
   self = qv
   }
   
   public init(asGuarenteed newValue: QuantumableGuarenteed) {
   self = newValue.asQuantumValueGuarenteed
   }
   
   public init?(asOptional newValue: QuantumableOptional?) {
   guard let qv = newValue?.asQuantumValueOptional else {
   return nil
   }
   self = qv
   }
   
   public init(asThrowing newValue: QuantumableThrowing) throws {
   self = try newValue.asQuantumValueThrowing
   }
   
   */
  
  // public init(_ newValue: Codable?) {
  //   if let newValue = newValue {
  //     self.init(newValue)
  //   } else {
  //     return nil
  //   }
  // }
  
  // public var codableValue: Codable {
  //   switch self {
  //     case let .int(int): return int
  //     case let .double(double): return double
  //     case let .string(string): return string
  //     // case let .date(date): return date
  //     case let .bool(bool): return bool
  //     // case let .uuid(uuid): return uuid
  //     case let .data(data): return data
  //       // case let .json(json): return json
  //       // case let .array(array): return array
  //       // case .dictionary(let dictionary):
  //       // return dictionary
  //   }
  // }
  
  internal enum QuantumError: Error {
    case missingValue
  }
  
  private struct MissingValueStuct: Codable, Equatable { }
  public static var MissingValue: QuantumValue {
    try! MissingValueStuct().asJSON.asQuantumValue
  }
  
  var isMissingValue: Bool {
    guard let _ = try? JSONData(self).jsonTo(MissingValueStuct.self) else { return false }
    return true
  }
  
  static var MissingValueAsserting: QuantumValue {
    assertionFailure()
    // return QuantumValue.uuid(UUID.zero)
    return MissingValue
  }
  // https://stackoverflow.com/questions/48297263/how-to-use-any-in-codable-type
  
  
  
  public func hash(into hasher: inout Hasher) {
    //    hasher.combine(self.typedValue())
    switch self {
      case let .int(int): return int.hash(into: &hasher)
      case let .double(double): return double.hash(into: &hasher)
      case let .string(string): return string.hash(into: &hasher)
        // case let .date(date): return date
      case let .bool(bool): return bool.hash(into: &hasher)
        // case let .uuid(uuid): return uuid
      case let .data(data): return data.hash(into: &hasher)
        // case let .json(json): return json
        // case let .array(array): return array
        // case .dictionary(let dictionary):
        // return dictionary
    }
  }
  
  
}



public extension Optional where Wrapped == QuantumValue? { // can't generalize this to "Optional" because of language nesting limitation
  var doubleUnwrapped: QuantumValue? {
    if isNil { return nil }
    return self! // .unsafelyUnwrapped
  }
}
