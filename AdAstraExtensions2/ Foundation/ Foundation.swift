//
//  Swift File.swift
//  Swift File
//
//  Created by CMS on 10/29/21.
//

import Foundation
import CryptoKit


#if os(iOS)
public let iOSPlatform: Bool = true
public let macOSPlatform: Bool = false
#elseif os(macOS)
public let iOSPlatform: Bool = false
public let macOSPlatform: Bool = true
#endif



public extension NSObject {
  var typeName: String {
    return String(describing: type(of: self))
  }

  static var TypeName: String {
    return String(describing: self)
  }
}



public extension UUID {
  // static let zero = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!
  static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

public extension Bool {
  var negated: Bool { !self }
  var not: Bool { !self }
  var opposite: Bool { !self }
  var isFalse: Bool { !self }
  var isOff: Bool { !self }
  var isTrue: Bool { self }
}

// extension Bool: Equatable{
// 	public static func == (lhs: Bool, rhs: Bool) -> Bool {
// 		lhs == rhs
// 	}
// }


public extension Date {
//  @available(iOS 10, obsoleted 15, *)
//  @available(macOS 10, obsoleted 12, *)
  static var nownow: Date { Date(timeIntervalSinceNow: 0) }
}

// #if DEBUG
public enum ToDoIssueLevel {
  case releasable
  #if !RELEASE
  case moderateImportance
  case highImportance
  #if DEBUG
  case criticalImportance
  #endif
  #endif
}
 






public extension DispatchTimeInterval {
  func toDouble() -> Double? {
    var result: Double? = 0

    switch self {
      case let .seconds(value):
        result = Double(value)
      case let .milliseconds(value):
        result = Double(value) * 0.001
      case let .microseconds(value):
        result = Double(value) * 0.000001
      case let .nanoseconds(value):
        result = Double(value) * 0.000000001

      case .never:
        result = nil
    }

    return result
  }
}


// public extension Data {
//   static var Assert: Data {
//     assert(false)
//     return Data()
//   }
// }

import CryptoKit

public extension Data {
  var checksum: String? {
    SHA256.hash(data: self).description
  }
}
