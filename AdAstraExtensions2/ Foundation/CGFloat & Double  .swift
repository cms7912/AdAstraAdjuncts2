//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
import CoreGraphics

extension Int: DebugDescription {
  public var dd: String { "\(self)" }

  public var asCGFloat: CGFloat { CGFloat(self) }
  public var asDouble: Double { Double(self) }
}

public extension Double {
  /// Rounds the double to decimal places value
  func rounded(to places: Int = 0) -> Double {
    let divisor: Double = pow(10.0, Double(places))
    let rounded = Darwin.round(self * divisor) / divisor
    return rounded
  }

  // adapted from: https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift

  func asPercentage(decimals: Int = 0, moveDecimal: Bool = true) -> String {
    let adjusted: Double = self * (moveDecimal ? 100 : 1)
    let newValue: Double = adjusted.rounded(to: decimals)
    if newValue.isNaN { return "%" }
    return String(format: "%." + String(decimals) + "f", newValue) + "%"
  }

  func asString(decimals: Int = 0) -> String {
    String(format: "%." + String(decimals) + "f", self)
  }

  func asCurrency() -> String? {
    let formatter = NumberFormatter()
    //        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
    formatter.numberStyle = .currency
    if let formattedAmount = formatter.string(from: self as NSNumber) {
      return formattedAmount
    }
    // adapted from: https://stackoverflow.com/questions/41558832/how-to-format-a-double-into-currency-swift-3
    return nil
  }
}

extension CGFloat: DebugDescription {
  public var dd: String { "\(asString(decimals: 1))" }
}


public extension CGFloat {
  func asString(decimals: Int = 0) -> String {
    String(format: "%." + String(decimals) + "f", self)
  }
}

public extension Optional where Wrapped == CGFloat {
  var as0IfNil: CGFloat { asZeroIfNil }
  var ifNil0: CGFloat { asZeroIfNil }
  var asZeroIfNil: CGFloat {
    guard let unwrapped = self else {
      return .zero
    }
    return unwrapped
  }

  var asNilIfZero: CGFloat? {
    guard let unwrapped = self, unwrapped != .zero else {
      return nil
    }
    return unwrapped
  }
}


public extension Optional where Wrapped == CGFloat {
  static func + (lhs: CGFloat?, rhs: CGFloat) -> CGFloat? {
    guard let lhs = lhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: CGFloat?, rhs: CGFloat) -> CGFloat? {
    guard let lhs = lhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: CGFloat?, rhs: CGFloat) -> CGFloat? {
    guard let lhs = lhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: CGFloat?, rhs: CGFloat) -> CGFloat? {
    guard let lhs = lhs else { return nil }
    return lhs / rhs
  }


  static func + (lhs: CGFloat, rhs: CGFloat?) -> CGFloat? {
    guard let rhs = rhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: CGFloat, rhs: CGFloat?) -> CGFloat? {
    guard let rhs = rhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: CGFloat, rhs: CGFloat?) -> CGFloat? {
    guard let rhs = rhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: CGFloat, rhs: CGFloat?) -> CGFloat? {
    guard let rhs = rhs else { return nil }
    return lhs / rhs
  }


  static func + (lhs: CGFloat?, rhs: CGFloat?) -> CGFloat? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: CGFloat?, rhs: CGFloat?) -> CGFloat? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: CGFloat?, rhs: CGFloat?) -> CGFloat? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: CGFloat?, rhs: CGFloat?) -> CGFloat? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs / rhs
  }
}





public extension Optional where Wrapped == Double {
  static func + (lhs: Double?, rhs: Double) -> Double? {
    guard let lhs = lhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: Double?, rhs: Double) -> Double? {
    guard let lhs = lhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: Double?, rhs: Double) -> Double? {
    guard let lhs = lhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: Double?, rhs: Double) -> Double? {
    guard let lhs = lhs else { return nil }
    return lhs / rhs
  }


  static func + (lhs: Double, rhs: Double?) -> Double? {
    guard let rhs = rhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: Double, rhs: Double?) -> Double? {
    guard let rhs = rhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: Double, rhs: Double?) -> Double? {
    guard let rhs = rhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: Double, rhs: Double?) -> Double? {
    guard let rhs = rhs else { return nil }
    return lhs / rhs
  }


  static func + (lhs: Double?, rhs: Double?) -> Double? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs + rhs
  }

  static func - (lhs: Double?, rhs: Double?) -> Double? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs - rhs
  }

  static func * (lhs: Double?, rhs: Double?) -> Double? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs * rhs
  }

  static func / (lhs: Double?, rhs: Double?) -> Double? {
    guard let lhs = lhs, let rhs = rhs else { return nil }
    return lhs / rhs
  }
}


public extension AdditiveArithmetic {
  var asBool: Bool {
      return self != .zero
  }
}

public extension Bool {
  var asInteger: Int {
    self ? 1 : 0
  }
}
