//
//  File.swift
//
//
//  Created by cms on 1/16/22.
//

import Foundation
import os.log

/*
 call site:
 TemplateStruct[.name].asString
 */

extension Dictionary where Key == String, Value == Codable {
  func encodeToJSON() { }
}

struct TemplateStruct: CodableDictionaryProtocol {
  typealias PropertyProtocol = Property

  enum Property: String {
    case name
    case age
    case photo
  }

  @CodableDictionary var dictionaryStore = [Property: QuantumValue]()

  init() { } // empty struct

  /// create struct with this dictionary loaded
  // init(dict: [Property: Codable]) { Self.Init(dict: dict, &_dictionaryStore.wrappedValue) }

  /// create struct with this dictionary loaded, keys of optional values are dropped
  // init(dict: [Property: Codable?]) { Self.Init(dict: dict, &_dictionaryStore.wrappedValue) }


  // .... non-working example ....
  // @DictBacked("name", dictStore) var name: String
  // @DictBacked("age", dictStore) var age: Int
  // @DictBacked("photo", dictStore) var photo: Image
}

/*
 The goals of CodableDictionaryStruct:
  - store data in a [String:Codable] dictionary
  - dictionary can easily expand with future data needs
  - backward-compatible so old version don't delete unknown data
  - named and typed variables for consistency

 Testing in Playgrounds shows this is robust and reliable.
 Using QuantumValue over AnyCodable because it stores and returns a strongly-typed value. AnyCodable only returns an 'Any' that must be cast on call site. (This could work better if host structure had computed variables doing so, but that added complexity to every struct to have a a getter & setter on every variable.) ((Future thinking: this would be a good use of property wrappers--though the property wrapper would need both the string variable name passed in and the dictionary store passed in ))
 Anecdotal comments on StackOverflow point to JSON not storing more than int, double, bool, and string, dictionaries, and arrays... all other datatypes are down casts to strings. (See AnyCodable's link).

 */


// public protocol CodableDictionaryStruct: Codable {
public protocol CodableDictionaryProtocol: Codable {
  associatedtype PropertyProtocol: Hashable & RawRepresentable

  var dictionaryStore: [PropertyProtocol: QuantumValue] { get set }
}

// extension Dictionary where Value == QuantumValue {
// 	subscript(_ key: Key) -> QuantumValue {
// 		get { self[key]! }
// 		set { self[key] = newValue }
// 	}
// }

public extension CodableDictionaryProtocol { // inits:
  static func Init(dict: [PropertyProtocol: Quantumable], _ wrappedDictionary: inout [PropertyProtocol: QuantumValue]) {
    wrappedDictionary = dict.mapValues{ value in
      (try? QuantumValue(value)) ?? QuantumValue.MissingValue
    }
  }

  static func Init(dict: [PropertyProtocol: Quantumable?], _ wrappedDictionary: inout [PropertyProtocol: QuantumValue]) {
    let tupleArray = dict.compactMap{ (key: PropertyProtocol, value: Quantumable?) -> (PropertyProtocol, QuantumValue)? in
      if let value, let qv = try? QuantumValue(value) {
        return (key, qv)
      } else {
        return nil
      }
    }
    wrappedDictionary = Dictionary(uniqueKeysWithValues: tupleArray)
  }

  // static func From(dict dictionary: [String:Any?]){
  // 	l4et s = Self()
  // 	s.
  // }
}

/*
 public extension CodableDictionaryStruct {

 	subscript(_ property: PropertyProtocol) -> AnyCodable? {
 		get { dictionaryStore[property] }
 		set { dictionaryStore[property] = newValue }
 	}

 	subscript(_ property: PropertyProtocol) -> Int? {
 		get { dictionaryStore[property]?.value as? Int }
 		set { if let newValue = newValue {
 			dictionaryStore[any: property] = newValue
 		} else {
 			dictionaryStore.removeValue(forKey: property); return }
 		} }

 	subscript(_ property: PropertyProtocol) -> String? {
 		get { dictionaryStore[property]?.value as? String }
 		set { if let newValue = newValue {
 			// dictionaryStore[property] = AnyCodable(value: newValue)
 			dictionaryStore[any: property] = newValue
 		} else {
 			dictionaryStore.removeValue(forKey: property); return }
 		} }

 }
 extension Dictionary where Value == AnyCodable {
 	subscript(any key: Key) -> Any? {
 		get { self[key] }
 		set { self[key] = AnyCodable(value: newValue) }
 	}
 }
 */


public extension CodableDictionaryProtocol {
  // extension Dictionary where Value == QuantumValue {
  // 	subscript(_ key: Key) -> QuantumValue {
  // 		get { self[key]! }
  // 		set { self[key] = newValue }
  // 	}
  // }

  subscript(_ property: PropertyProtocol) -> QuantumValue {
    get { dictionaryStore[property]! }
    set { dictionaryStore[property] = newValue }
  }

  subscript(_ property: PropertyProtocol) -> Int? {
    get { try? dictionaryStore[property]?.asInt }
    set { if let newValue = newValue {
      dictionaryStore[property] = .int(newValue)
    } else {
      dictionaryStore.removeValue(forKey: property); return }
    } }


  subscript(_ property: PropertyProtocol) -> Double? {
    get { try? dictionaryStore[property]?.asDouble }
    set { if let newValue = newValue {
      dictionaryStore[property] = .double(newValue)
    } else {
      dictionaryStore.removeValue(forKey: property); return }
    } }


  subscript(_ property: PropertyProtocol) -> String? {
    get { try? dictionaryStore[property]?.asString }
    set { if let newValue = newValue {
      dictionaryStore[property] = .string(newValue)
    } else {
      dictionaryStore.removeValue(forKey: property); return }
    } }

  // subscript(_ property: PropertyProtocol) -> Date? {
  //   get { dictionaryStore[property]?.asDate }
  //   set { if let newValue = newValue {
  //     dictionaryStore[property] = .date(newValue)
  //   } else {
  //     dictionaryStore.removeValue(forKey: property); return }
  //   } }

  subscript(_ property: PropertyProtocol) -> Bool? {
    get { try? dictionaryStore[property]?.asBool }
    set { if let newValue = newValue {
      dictionaryStore[property] = .bool(newValue)
    } else {
      dictionaryStore.removeValue(forKey: property); return }
    } }

  subscript(_ property: PropertyProtocol) -> Data? {
    get { try? dictionaryStore[property]?.asData }
    set { if let newValue = newValue {
      dictionaryStore[property] = .data(newValue)
    } else {
      dictionaryStore.removeValue(forKey: property); return }
    } }
}


public extension CodableDictionaryProtocol { // un/archiving:
  func unarchive<DecodedObjectType>(_ dataProperty: PropertyProtocol, into destType: DecodedObjectType.Type) -> DecodedObjectType? where DecodedObjectType: NSObject, DecodedObjectType: NSCoding {
    try? NSKeyedUnarchiver.unarchivedObject(ofClass: destType, from: dictionaryStore[dataProperty]?.asData ?? Data())
    return nil
  }

  func unarchive(_ dataProperty: PropertyProtocol, into classes: [AnyClass]) -> Any? {
    try? NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: dictionaryStore[dataProperty]?.asData ?? Data())
  }

  func archive(_ value: Any?, into dataStore: inout Data?) {
    if value == nil { dataStore = nil; return }
    do{
      dataStore = try NSKeyedArchiver.archivedData(withRootObject: value!, requiringSecureCoding: true)
    } catch {
//      CrashDuringDebug🛑("failed to archive data that was not nil")
      assertionFailure()
      dataStore = nil
    }
    // need to use 'inout' instead of direct assignment. The protocol doesn't know about the propertyWrapper '@CodableDictionary' but apparently it does know the instance is a struct ... and therefore errors that self is immutable.
  }

  var jsonEncoded: Data? {
    do {
      return try JSONEncoder.encode(self)
    } catch {
//      CrashDuringDebug🛑("failed to encode an  existing self")
      assertionFailure()
      return nil
    }
  }
}


@propertyWrapper
public struct CodableDictionary<Key: Hashable & RawRepresentable, Value: Codable>: Codable where Key.RawValue: Codable & Hashable {
  public var wrappedValue: [Key: Value]

  public var rawDictionary: [Key.RawValue: Value] {
    Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue, $1) })
  }

  public init() {
    wrappedValue = [:]
  }

  public init(wrappedValue: [Key: Value]) {
    self.wrappedValue = wrappedValue
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawKeyedDictionary = try container.decode([Key.RawValue: Value].self)

    wrappedValue = [:]
    for (rawKey, value) in rawKeyedDictionary {
      guard let key = Key(rawValue: rawKey) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Invalid key: cannot initialize '\(Key.self)' from invalid '\(Key.RawValue.self)' value '\(rawKey)'"
        )
      }
      wrappedValue[key] = value
    }
  }

  public init(from unknownDictionary: [String: Codable]) throws {
    // let container = try decoder.singleValueContainer()
    guard let rawKeyedDictionary = unknownDictionary as? [Key.RawValue: Value] else { throw Self.ErrorOut() }

    wrappedValue = [:]
    for (rawKey, value) in rawKeyedDictionary {
      guard let key = Key(rawValue: rawKey) else { throw Self.ErrorOut() }
      wrappedValue[key] = value
    }
  }

  static func ErrorOut() -> Error {
    DecodingError.typeMismatch(NSDictionary.self, .init(codingPath: [], debugDescription: "attempted unknownDictionary, failed", underlyingError: nil))
  }


  public func encode(to encoder: Encoder) throws {
    let rawKeyedDictionary = Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue, $1) })
    var container = encoder.singleValueContainer()
    try container.encode(rawKeyedDictionary)
  }

  // https://www.fivestars.blog/articles/codable-swift-dictionaries/
}



