//
//  File 2.swift
//
//
//  Created by Clint Ramirez Stephens  on 3/25/23.
//
import Foundation

extension QuantumValue // Debugging check for incorrect type
{
  static var qvCheckInProgress: Bool = false
  func checkForIncorrectType() {
    #if DEBUG
    if Self.qvCheckInProgress{ return }
    Self.qvCheckInProgress = true
    if false {
    } else if (try? asInt) != nil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asInt has the value")
      assertionFailure()
    } else if (try? asDouble).isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDouble has the value")
      assertionFailure()
    } else if (try? asString).isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asString has the value")
      assertionFailure()
      // } else if asDate.isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDate has the value")
      assertionFailure()
    } else if (try? asBool).isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asBool has the value")
      assertionFailure()
      // } else if asUUID.isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asUUID has the value")
      assertionFailure()
    } else if (try? asData).isNotNil {
//      CrashDuringDebug🛑("QuantumValue accessed wrong case, .asData has the value")
      assertionFailure()
      // } else if asJSONData.isNotNil {
      //   CrashDuringDebug🛑("QuantumValue accessed wrong case, .json has the value")
      // } else if asArray.isNotNil {
      // CrashDuringDebug🛑("QuantumValue accessed wrong case, .asArray has the value")
      // } else if asDictionary.isNotNil {
      // CrashDuringDebug🛑("QuantumValue accessed wrong case, .asDictionary has the value")
    }
    #endif
  }
}



public extension QuantumValue // representing true/false
{
  var representingTrueOrFalse: Bool? {
    Self.RepresentingTrueOrFalse(self)
  }

  static func RepresentingTrueOrFalse(_ value: QuantumValue) -> Bool? {
    switch value {
      case let .int(int):
        return int != .zero
      case let .double(double):
        return double != .zero
      case let .string(string):
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() // else { return nil }
        if trimmedString == "true" || trimmedString == "t" {
          return true
        }
        if trimmedString == "false" || trimmedString == "f" {
          return false
        }
        if let dbl = Double(trimmedString) {
          return Self.RepresentingTrueOrFalse(dbl.asQuantumValue)
        }
        return nil
      // case let .date(_):
      case let .bool(bool):
        return bool
      // case let .uuid(_):
      // case let .data(data):
      /*
       case let .json(json):
       
       if let newValue: Quantumable = (data.jsonMaybeTo(Int.self) ??
         data.asJSON?.jsonMaybeTo(Double.self) ??
         data.asJSON?.jsonMaybeTo(String.self) ??
         data.asJSON?.jsonMaybeTo(Bool.self)
       ) {
         return Self.RepresentingTrueOrFalse(newValue.asQuantumValue)
       }
       if let newValue = json?.jsonMaybeTo(QuantumValue.self) {
         return Self.RepresentingTrueOrFalse(newValue)
       }
       return nil
       */
      // case let .array(array):
      // case .dictionary(let dictionary):
      default:
        return nil
    }
  }
}
