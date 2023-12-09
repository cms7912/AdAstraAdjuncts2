//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
import SwiftUI

public protocol DebugDescription {
  var dd: String { get }
}

// extension NSObject: OptionalOptional { }

public protocol OptionalNonOptional {
}

public extension OptionalNonOptional {
  
  @discardableResult
  func assertIfNil() -> Self? {
    return self
  }
}

#if true
public extension Optional {
  @discardableResult
  func assertIfNil() -> Wrapped? {
    if let unwrapped = self { return unwrapped }
    // CrashDuringDebug()
    assertionFailure()
    return nil
  }
}
#endif

public extension Optional {
  var dd: String {
    guard let unwrapped = self else { return "nil"}
    if let unwrapped = unwrapped as? DebugDescription {
      return unwrapped.dd
    }
    return "\(unwrapped)"
  }

  var isNil: Bool {
    self == nil
  }

  var isNotNil: Bool {
    self != nil
  }
}


public extension Optional {
  func unwrapAssertOr(_ alternate: Wrapped) -> Wrapped {
    if let unwrapped = self { return unwrapped }
    // CrashDuringDebug()
    assertionFailure()
    return alternate
  }

  // var test: CGFloat?
  // test.unwrapAssertOr(0)
  // -- unwrap, but during debug if nil then assert failure. Or during release return alternate value given
}



public extension Optional where Wrapped: Collection {
  var isEmptyOrNil: Bool {
    self?.isEmpty ?? true
  }

  var isNilOrEmpty: Bool {
    isEmptyOrNil
  }

  var asNilIfEmpty: Wrapped? {
    isEmptyOrNil ? nil : self
  }

  // https://gist.github.com/zakbarlow1995/885fc55edccc443ccec6a2fc54ec47a5

  var asEmptyIfNil: any Collection {
    if let unwrapped = self { return unwrapped }
    return [Wrapped.Element]()
  }
}

// public extension Optional where Wrapped: Sequence  {
//
// 	var asEmptyIfNil: Wrapped {
// 		if let unwrapped = self { return unwrapped  }
// 		// return [Wrapped.Element]()
// 		Wrapped.empty
// 	}
// }

// public extension Optional where Wrapped: NSSet  {
// 	var asEmptyIfNil: NSSet {
// 		if let unwrapped = self { return unwrapped  }
// 		return NSSet()
// 	}
// }

public extension Optional where Wrapped: ExpressibleByArrayLiteral {
  var asEmptyIfNil: Wrapped {
    if let unwrapped = self { return unwrapped }
    return Wrapped()
  }
}


public extension Optional where Wrapped == Bool {
  var nilIsFalse: Bool{
    guard let unwrapped = self else { return false}
    return unwrapped
  }

  var nilIsTrue: Bool{
    guard let unwrapped = self else { return true}
    return unwrapped
  }

  var asFalseIfNil: Bool { nilIsFalse }
  var asTrueIfNil: Bool { nilIsTrue }
}



// postfix operator !? // disallowed
// postfix operator !? // disallowed
// postfix operator !! // disallowed
// postfix operator ?? // disallowed
// postfix operator ⁉️
postfix operator ~! // works
postfix operator *! // works
postfix operator *!* // works
postfix operator ^!^ // works
postfix operator ⁉️ // works
// postfix operator ?! //
public extension Optional {
  static func UnwrappingOptionalForcefullyFailed() -> Never {
//    NSObject.CrashAfterUserAlert("")
    fatalError()
  }

  static postfix func *!* (optionalObject: Wrapped?) -> Wrapped {
    if optionalObject == nil {
      // fatalError()
      Self.UnwrappingOptionalForcefullyFailed()
    }
    return optionalObject!
  }



  static postfix func ^!^ (optionalObject: Wrapped?) -> Wrapped {
    optionalObject*!*
  }

  static postfix func ⁉️ (optionalObject: Wrapped?) -> Wrapped {
    optionalObject*!*
  }

  static postfix func ~! (optionalObject: Wrapped?) -> Wrapped? {
    // optionalObject*!*
    if let unwrapped = optionalObject { return unwrapped }
    assertionFailure()
    return nil
  }

  static postfix func *! (optionalObject: Wrapped?) -> Wrapped? {
    // optionalObject*!*
    if let unwrapped = optionalObject { return unwrapped }
    assertionFailure()
    return nil
  }
}

public extension Optional {
  func ifNilThrow(_ error: String) throws -> Wrapped {
    try ifNilThrow(error: OptionalError.reason(error))
  }

  func ifNilThrow(_ error: OptionalError = OptionalError.reason("not given")) throws -> Wrapped {
    try ifNilThrow(error: error)
  }

  func ifNilThrow(_ error: Error) throws -> Wrapped {
    try ifNilThrow(error: error)
  }

  // func ifNilThrow(_ error: OptionalError) throws -> Wrapped {
  // 	try self.ifNilThrow(error)
  // }
  private func ifNilThrow(error: Error) throws -> Wrapped {
    if isNil { throw error }
    return self!
  }

  enum OptionalError: Error {
    case reason(String)
  }
}

public extension Optional {
  func ifNilThen(_ closure: () -> Wrapped) -> Wrapped {
    if isNil { return closure() }
    return self!
  }
}

public extension Optional where Wrapped == Data {
  var emptyIfNil: Data {
    if let unwrapped = self { return unwrapped }
    return Data()
  }
}

public extension Optional where Wrapped == UUID {
  var IfNilAssertRandom: UUID {
    if let unwrapped = self { return unwrapped }
    assertionFailure()
    return UUID()
  }
}



extension NSAttributedString {
  convenience init?(string: String?) {
    guard let string else { return nil }
    self.init(string: string)
  }
}

public extension NSObject {
  static var Assert: Self {
    assertionFailure()
    return Self()
  }
}


// infix operator ?!: NilCoalescingPrecedence
// /// Throws the right hand side error if the left hand side optional is `nil`.
// func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
//   guard let value = value else {
//     throw error()
//   }
//   return value
// }
// // https://www.avanderlee.com/swift/unwrap-or-throw/



