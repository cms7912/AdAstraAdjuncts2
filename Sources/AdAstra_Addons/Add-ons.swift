//
//  File.swift
//  
//
//  Created by Clint Ramirez Stephens  on 6/24/23.
//

import Foundation

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

import AALogger
public func ToDo(_: ToDoIssueLevel, _ string: String = "") {
  LLog("🚧🛠🧱 ToDo: \(string)")
}

// #endif
// use as:  ToDo(.highImportance, "Remove this later")
// https://ericasadun.com/2018/04/18/forcing-compiler-errors-in-swift/




enum TimeStamp {
 static let calendar = Calendar.current
 static let date = Date()
 //  static let hour = calendar.component(.hour, from: date)
 static let hour24 = calendar.component(.hour, from: date) // hour24calc()
 static let minutes = calendar.component(.minute, from: date)
 static let minutes00 = calendar.component(.minute, from: date)
 //  static func hour24calc() -> String {
 //    if hour > 12 {
 //      return String(hour + 12)
 //    } else {
 //      if hour < 10 {
 //        return "0\(hour)"
 //      } else {
 //        return "\(hour)"
 //      }
 //    }
 //  }
 static func minutes00calc() -> String {
   if minutes < 10 {
     return "0\(minutes)"
   } else {
     return "\(minutes)"
   }
 }
}
