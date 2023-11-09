//
//  File.swift
//
//
//  Created by cms on 1/18/22.
//

import Foundation
//import AALogger
// import CoreData

typealias MetadataDictionary = [String: Codable]
public var JSONEncoder = Foundation.JSONEncoder()
public var JSONDecoder = Foundation.JSONDecoder()


public struct JSONData: Codable, Hashable, Equatable {
  public static var Empty: JSONData = JSONData(Data())
  public static var EmptyAndAssert: JSONData {
    assertionFailure()
    return Self.Empty
  }

  public init(_ d: Data) { data = d }
  public init(_ d: Encodable) throws { data = (try JSONEncoder.encode(d)) }
  public init?(_ d: Encodable?) throws {
    guard let d else { return nil }
    do {
      try self.init(d)
    } catch {
//      LLog("JSONData error:\(error.localizedDescription)")
      throw error
    }
  }

  public var data: Data
}

public extension JSONData{
  func jsonTo<T>(_: T.Type) throws -> T where T: Decodable {
    do {
      return try JSONDecoder.decode(T.self, from: data)
    } catch {
//      LLog("jsonTo error:\(error.localizedDescription)")
      throw error
    }
  }

  func jsonMaybeTo<T>(_: T.Type) -> T? where T: Decodable {
    try? JSONDecoder.decode(T.self, from: data)
  }

  var jsonText: String? {
    return String(data: data, encoding: .utf8)
  }
}

public protocol JSONCodable: Codable { }
public extension JSONCodable {
  var asJSON: JSONData { get throws {
    try JSONData(self)
  } }
  var asJSONOpt: JSONData? {
    try? JSONData(self)
  }

  static func fromJSON(_ jsonData: JSONData) throws -> Self {
    // guard let jsonData else { return nil }

    do {
      return try JSONDecoder.decode(Self.self, from: jsonData.data)
    } catch {
//      LLog("jsonTo: \(error.localizedDescription)")
      throw error
    }
  }

  static func fromJSONOpt(_ jsonData: JSONData?) -> Self? {
    guard let jsonData else { return nil }

    do {
      return try JSONDecoder.decode(Self.self, from: jsonData.data)
    } catch {
//      LLog("jsonTo :\(error.localizedDescription)")
      return nil
    }
  }
}

public extension Encodable {
  var asJSON: JSONData { get throws {
    try JSONData(self)
  } }
}

public extension Decodable {
  static func fromJSON(_ jsonData: JSONData?) -> Self? {
    try? JSONDecoder.decode(Self.self, from: jsonData?.data ?? Data())
  }
}

public extension Data{
  var jsonText: String? {
    return String(data: self, encoding: .utf8)
  }

  // func jsonTo<T>(_: T.Type) -> T? where T: Decodable {
  //   try? JSONDecoder.decode(T.self, from: self)
  // }

  func jsonTo<T>(_: T.Type) throws -> T where T: Decodable {
    try JSONDecoder.decode(T.self, from: self)
  }

  // func asJSON() -> JSONData? {
  //   JSONData(self)
  // }

  func asJSON() throws -> JSONData {
    JSONData(self)
  }
}

public extension String {
  var asData: Data? {
    data(using: String.Encoding.utf8, allowLossyConversion: false)
  }

  var asJSON: JSONData? { get throws {
    try JSONData(self)
  } }
  static func fromJSON(_ jsonData: JSONData?) -> Self? {
    try? JSONDecoder.decode(Self.self, from: jsonData?.data ?? Data())
  }
}

public extension Dictionary where Key: Codable, Value: Codable {
  var asJSON: JSONData { get throws {
    try JSONData(self)
  } }

  static func fromJSON(_ jsonData: JSONData?) -> Self? {
    try? JSONDecoder.decode(Self.self, from: jsonData?.data ?? Data())
  }
}


// public extension AttributedString {
//   var asJSON: JSONData? {
//     JSONData(self)
//   }
//
//   static func fromJSON(_ jsonData: JSONData?) -> Self? {
//     try? JSONDecoder.decode(Self.self, from: jsonData?.data ?? Data() )
//   }
// }


// @propertyWrapper
// struct MetadataStore {
// 	public var wrappedValue: [String: Codable] {
// 		get {
// 			let data = (backingObject.value(forKey: storeKey) as? Data) ?? Data()
// 			// return data.jsonTo(MetadataDictionary) ?? [String: Codable]()
// 		}
// 		set {
//
// 			// let data = newValue.asJSON
// 			// backingObject.setValue(data, forKey: storeKey)
// 		}
// 	}
//
// 	public init(_ object: NSManagedObject, _ storeKey: String = "metadataDictionary" ) {
// 		// wrappedValue = [:]
// 		self.backingObject = object
// 		self.storeKey = storeKey
// 	}
// 	let backingObject: NSManagedObject
// 	let storeKey: String
//
//
// 	// public init(wrappedValue: [String: Codable]) {
// 	// 	self.wrappedValue = wrappedValue
// 	// }
//
// }


/*
 resources:
 https://www.fivestars.blog/articles/codable-swift-dictionaries/
 https://book.hacktricks.xyz/mobile-apps-pentesting/ios-pentesting/ios-serialisation-and-encoding
 https://medium.com/swift-india/use-of-codable-with-jsonencoder-and-jsondecoder-in-swift-4-71c3637a6c65
 https://levelup.gitconnected.com/custom-encoding-and-decoding-json-in-swift-a99c80b280e7

 https://quickbirdstudios.com/blog/swift-property-wrappers/

 https://developer.apple.com/documentation/foundation/jsonencoder
 https://github.com/marksands/BetterCodable

 https://nshipster.com/nssecurecoding/

 */

