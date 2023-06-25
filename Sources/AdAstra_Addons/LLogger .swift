//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation

// import SwiftUI
// import UIKit
// import CoreData
// import SFSafeSymbols

import SwiftUI
import os.log

// import AdAstraAnalytics

/*
 class-specific function

 func llog(_ string: String, function: String = #function) {
 if (HighlightDebug.* {n	 super.llog("🍇 \(string)", function: function)
 }
 }


 */

//import Pulse

// https://kean-docs.github.io/pulse/documentation/pulse/gettingstarted/
/*

 <key>NSLocalNetworkUsageDescription</key>
 <string>Network usage required for debugging purposes </string>
 <key>NSBonjourServices</key>
 <array>
   <string>_pulse._tcp</string>
 </array>

 */

// To display console view: Pulse.ConsoleView()


public extension Logger {
  static var CurrentLogLevel = OSLogType.error

  static func ExtractFilename(from fullPath: String) -> String {
    // Extract the filename from the full path
    var filename: String = (fullPath as NSString).deletingPathExtension
    filename = (filename as NSString).lastPathComponent
    filename = filename.trimmingCharacters(in: .whitespaces)
    return filename
  }

  static func ExtractMethodName(from function: String) -> String {
    if let regex = try? NSRegularExpression(pattern: "\\([^\\)]*\\)") {
      return regex.stringByReplacingMatches(
        in: function,
        options: [],
        range: NSRange(location: 0, length: function.count),
        withTemplate: ""
      )
    }
    return function
  }


  static func BuildLogEntryFrom(
    _ condition: Bool = true,
    _ message: Any? = nil,
    _ level: OSLogType? = nil,
    filepath: String,
    function: String,
    line _: Int,
    logPrefix: String? = nil
  ) {
    // print("conditionReceived: \(condition)")
    guard (condition && (level.isNil ||
        (level.isNotNil && (level!.rawValue >= CurrentLogLevel.rawValue))
    )
    ) else { return }

    var logLevelIndicator: String {
      guard let level = level else { return "" }
      switch level {
        case .error:
          return "⚠️"
        case .fault:
          return "🛑"
        default:
          return ""
      }
    }

    var timestamp: String = ""
    if #available(iOS 15, macCatalyst 15, macOS 12, *) {
      timestamp = String(Date.now.formatted(date: .omitted, time: .standard).dropLast(3))
    }

    // extract the thread:
    var thread: String = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) ?? ""
    #if DEBUG
    switch thread {
      case "com.apple.main-thread":
      thread = "main-thread"
      case "com.apple.root.user-interactive-qos":
      thread = "user-int-thread"
      default:

      // entirely remove any "NSManagedObjectContext 0x600002059d40"
      // most contexts have their own names)
      thread = thread.replacingOccurrences(
        of: "^NSManagedObjectContext ([0-9xabcdef]){14}",
        with: "",
        options: .regularExpression
      )
      // _ = 1
    }
    #endif
    // https://stackoverflow.com/questions/39553171/how-to-get-the-current-queue-name-in-swift-3

    // Extract the filename from the full path
    var filename = ExtractFilename(from: filepath)
    let prefix = logPrefix ?? ""

    // Extract the method name without the parameter list
    var methodName: String = ExtractMethodName(from: function)

    func getObjectAsString(_ object: Any?) -> String {
      var output: String = ""

      if object != nil {
        let mirror = Mirror(reflecting: object!)
        for (property, value) in mirror.children {
          guard let property = property else { continue }

          if ["id", "name"].contains(property) {
            output += "\(property):\(value); "
          }
        }
      }

      output += String(describing: object)

      return output
    }

    func messageAsString(_ myMessage: Any?) -> String {
      if myMessage != nil {
        if let int = myMessage as? Int {
          return String(int)
        }
        if let string = myMessage as? String {
          return string
        }
        if let array = myMessage as? [Any?] {
          let stringArray: [String] = array.map {messageAsString($0)}
          //                    return stringArray.reduce("", { $0 == "" ? $1 : $0 + "," + $1 })
          return stringArray.reduce("") { $0 + "," + $1 }
        }
        return getObjectAsString(myMessage)
      }
      return "" // 'nil'"
    }

    let fullMessage = messageAsString(message)

    var fullLogString: String = "\(timestamp) \(thread)|\(filename)|\(prefix)\(methodName)"
    // when 'message' is nil then simply show file name and method name
    if message != nil {
      //            fullLogString += ":L\(line): \(fullMessage)"
      fullLogString += ": \(fullMessage)"
    }
         // return fullLogString

         // self.appLogger.log(level: level, "\(fullLogString)")

    // self.appLogger.log("\(fullLogString)")
    #if Release
    switch level {
      case .fault:
      appLogger.fault("\(fullLogString)")
      case .debug:
      appLogger.debug("\(fullLogString)")
      case .error:
      appLogger.error("\(fullLogString)")
      case .info:
      appLogger.info("\(fullLogString)")
      default:
      appLogger.log("\(fullLogString)")
    }
    #else
    print(fullLogString)

    LoggerStore.shared.storeMessage(
      label: "auth",
      level: .debug,
      message: fullLogString // "Will login user",
      // metadata: ["userId": .string("uid-1")]
    )

    #endif
  }

  static var subsystemName: String { Bundle.main.bundleIdentifier ?? "AdAstraAppLoggerDefault" }
  // "app.caleo"

  /// The Logger instance that every llog function eventually calls to
  static let appLogger = Logger(subsystem: subsystemName, category: "main")


  // this is only for times that the below extensions aren't accessible (also requires 'import os.log' in that file)
  static func llog(if condition: Bool = true,
                   _ message: Any? = nil,
                   _ level: OSLogType? = nil,
                   filepath: String = #file,
                   function: String = #function,
                   line: Int = #line)
  {
    Logger.BuildLogEntryFrom(condition, message, level, filepath: filepath, function: function, line: line)
  }

  // helpful: https://medium.com/better-programming/ios-14s-new-logger-api-vs-oslog-ef88bb2ec237
}

// this is only for times that the below extensions aren't accessible (also requires 'import os.log' in that file)
// also check out protocol 'LLogging' below before using this
public func LLog(if condition: Bool = true,
                 _ message: Any? = nil,
                 _ level: OSLogType? = nil,
                 filepath: String = #file,
                 function: String = #function,
                 line: Int = #line)
{
  Logger.BuildLogEntryFrom(condition, message, level, filepath: filepath, function: function, line: line)
}

// // public extension ObservableObject: LLogging { }
//
// public extension ObservableObject {
//   var llogPrefix: String? { nil }
//   var llogIsEnabled: Bool { true }
//   func llog(if condition: Bool = true,
//             _ message: Any? = nil,
//             _ level: OSLogType = OSLogType.debug,
//             filepath: String = #file,
//             function: String = #function,
//             line: Int = #line ) {
//     if !(condition && llogIsEnabled)  { return }
//     Logger.BuildLogEntryFrom(message,
//                              level,
//                              filepath: filepath,
//                              function: function,
//                              line: line,
//                              logPrefix: llogPrefix ) }
// }
// // neither of these solutions work, primarily due to protocol-extension conformance limitations + NSManagedObject inheriting both NSObject and ObservableObject

public protocol ObservableObjectWithLLogging: ObservableObject, LLogging { }

public extension View {
  var llogPrefix: String? { nil }
  var llogIsEnabled: Bool { true }
  func llog(if condition: Bool = true,
            _ message: Any? = nil,
            _ level: OSLogType? = nil,
            filepath: String = #file,
            function: String = #function,
            line: Int = #line)
  {
    Logger.BuildLogEntryFrom(condition && llogIsEnabled,
                             message,
                             level,
                             filepath: filepath,
                             function: function,
                             line: line,
                             logPrefix: llogPrefix)
  }
}

public protocol LLogHandling: LLogging { }

extension LLogHandling { }


extension NSObject: LLogging {
  @objc open class func llogPrefix() -> String? { nil }
  @objc open func llogPrefix() -> String? { nil }
  // open var llogPrefix: String? { nil }
  // override class func llogPrefix() -> String? { "🎯" }

  public class func llog(if condition: Bool = true,
                         _ message: Any? = nil,
                         _ level: OSLogType? = nil,
                         filepath: String = #file,
                         function: String = #function,
                         line: Int = #line)
  {
    // Logger.BuildLogEntryFrom((condition && llogIsEnabled),
    Logger.BuildLogEntryFrom((condition),
                             message,
                             level,
                             filepath: filepath,
                             function: function,
                             line: line,
                             logPrefix: llogPrefix())
  }
}


public protocol LLogging {
  var llogPrefix: String { get }
  var llogIsEnabled: Bool { get }
}

public extension LLogging {
  var llogPrefix: String { "" }
  var llogIsEnabled: Bool {
    // print("default llogIsEnabled used")
    return true }

  func llog(if condition: Bool = true,
            _ message: Any? = nil,
            _ level: OSLogType? = nil,
            filepath: String = #file,
            function: String = #function,
            line: Int = #line) {
    let conditionResult = (condition && llogIsEnabled)
    // print ("conditionResult: \(conditionResult)")
    Logger.BuildLogEntryFrom(conditionResult,
                             message,
                             level,
                             filepath: filepath,
                             function: function,
                             line: line,
                             logPrefix: llogPrefix) }
}


