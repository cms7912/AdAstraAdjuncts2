//
//  File 2.swift
//
//
// Created by cms on 1/16/22.
//

import Foundation

public protocol Quantumable {
  // JSON handling uses try/throw/catch, so not expecting 'asQuantumValue' to always suceed without throwing an error
  var asQuantumValue: QuantumValue { get throws }
  init(_: QuantumValue) throws
}; extension Quantumable { }

#if Disabled
public extension Quantumable where Self == JSONData {
  init(_ qv: QuantumValue) throws {
    // self = try qv.to(JSONData.self).jsonTo(Self.self)
    self = try qv.asData.jsonTo(Self.self)
  }

  var asQuantumValue: QuantumValue {
    data.asQuantumValue
  }
}
#endif

public enum QuantumValue: JSONCodable, Equatable {
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

  public init(from decoder: Decoder) throws {
    if false { }
    else if let int = try? decoder.singleValueContainer().decode(Int.self) { self = .int(int) }
    else if let v = try? decoder.singleValueContainer().decode(Double.self) { self = .double(v) }
    else if let v = try? decoder.singleValueContainer().decode(String.self) { self = .string(v) }
    // else if let v = try? decoder.singleValueContainer().decode(Date.self) { self = .date(v) }
    else if let v = try? decoder.singleValueContainer().decode(Bool.self) { self = .bool(v) }
    // else if let v = try? decoder.singleValueContainer().decode(UUID.self) { self = .uuid(v) }
    else if let v = try? decoder.singleValueContainer().decode(Data.self) { self = .data(v) }
    // else if let v = try? decoder.singleValueContainer().decode(JSONData.self) { self = .json(v) }
    // else if let v = try? decoder.singleValueContainer().decode([QuantumValue].self) { self = .array(v) }
    // else if let v = try? decoder.singleValueContainer().decode(Dictionary<QuantumValue,QuantumValue>.self) { self = .dictionary(v) }

    throw QuantumError.missingValue
  }


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

  private struct MissingValueStuct: Codable { }
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
}



public extension Optional where Wrapped == QuantumValue? { // can't generalize this to "Optional" because of language nesting limitation
  var doubleUnwrapped: QuantumValue? {
    if isNil { return nil }
    return self! // .unsafelyUnwrapped
  }
}
