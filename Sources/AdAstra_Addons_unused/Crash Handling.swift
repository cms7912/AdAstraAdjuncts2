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
import AALogger

import os.log
import SwiftUI
// import AdAstraAnalytics

#if canImport(AdAstraBridgingByMask)
import AdAstraBridgingByMask
import AdAstraBridgingNSExtensions
#endif


// Crash Reporter

public extension NSObject {
	// static var CrashReporterDelegate: UIApplicationDelegate? { nil }

	static func CrashAfterUserAlert(
		_ message: String?,
		filepath: String = #file,
		function: String = #function,
		line: Int = #line
	) -> Never {
		Self.CrashAfterUserAlertHandler(message, filepath: filepath, function: function, line: line)
	}
	static func CrashAfterUserAlertHandler (
		_ logMessage: String?,
		_ userMessage: String? = "",
		filepath: String = #file,
		function: String = #function,
		line: Int = #line
	)  -> Never {

		// Add Handling of Crash Here //
		// - add logging to a crashReport folder
		// - add saving as possible

		// AnalyticsManager.shared.addTallyTo(.CaleoLoggerCrashReporterCount)

		LLog( "💥 \(logMessage.asEmptyIfNil)", filepath: filepath, function: function, line: line )
		assert(false)
		PresentUserAlertOfCrash(userMessage)
	}

	static func PresentUserAlertOfCrash( _ message: String?) -> Never {

		Logger.llog("CrashAfterUserAlert: \(message ?? "")")

		let title = "Unexpected Error"

		var fullMessage = """
Encountered unexpected condition. Data has been saved. If this continues please contact development for assistance.
"""
		if let message = message {
			fullMessage += "Reason for crash: \n" + message
		}

		let buttonText = "Exit"


		// Present alert to user
		#if os(iOS)
		let alertController = UIAlertController(title: title, message: fullMessage
												 , preferredStyle: .alert)
		alertController.addAction(
			UIAlertAction(title: buttonText, style: .default, handler: {_ in fatalError("\(message)") })
		)

		let rootViewController = UIApplication.shared.windows.first?.rootViewController
		rootViewController?.present(alertController, animated: true, completion: { })

		#else
		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = fullMessage
		alert.alertStyle = NSAlert.Style.warning
		alert.addButton(withTitle: buttonText)
		// return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
		alert.runModal()

		#endif
		fatalError("CrashAfterUserAlert called")
	}

	func crashAfterUserAlert(
		_ message: String?,
		filepath: String = #file,
		function: String = #function,
		line: Int = #line
	) -> Never {
		Self.CrashAfterUserAlertHandler(message, filepath: filepath, function: function, line: line)
	}

}

protocol CrashReporterDelegate {

}


public func CrashDuringDebug🛑(
	_ message: String = "",
	filepath: String = #file,
	function: String = #function,
	line: Int = #line
) {
	LLog( "💥 CrashDuringDebug 🛑 \(message)", filepath: filepath, function: function, line: line )
#if DEBUG
   let toggle = true
   // let toggle = false
	print("will crash if toggle unchanged")
	if toggle {
		fatalError("🛑CrashDuringDebug🛑 \(message)")
	}
#endif
}

public func CrashAfterUserAlert🛑(
	_ logMessage: String?,
	_ userMessage: String? = "",
	filepath: String = #file,
	function: String = #function,
	line: Int = #line
) -> Never {
	NSObject.CrashAfterUserAlertHandler(logMessage, userMessage, filepath: filepath, function: function, line: line)
}




struct LogEntryMetadata: Equatable {
	var message: String
	var filepath: String
	var function: String
	var line: Int
}
var AlertDuringDebug_IgnoredAlerts: [LogEntryMetadata] = [LogEntryMetadata]()

public func AlertDuringDebug📣(
	_ message: String = "",
	filepath: String = #file,
	function: String = #function,
	line: Int = #line
)  {
	LLog( "📣 AlertDuringDebug 📣 \(message)", filepath: filepath, function: function, line: line )

#if DEBUG
	let metadata = LogEntryMetadata(message: message,
									filepath: filepath,
									function: function,
									line: line)

	if AlertDuringDebug_IgnoredAlerts.contains(metadata) { return }

	// Present alert
	let alertController = UIAlertController(title: "Debug Reporting", message: message, preferredStyle: .alert)
	alertController.addAction(
		UIAlertAction(title: "OK", style: .default, handler: {_ in }) )

	alertController.addAction(
		UIAlertAction(title: "Skip in future", style: .destructive, handler: {_ in
			AlertDuringDebug_IgnoredAlerts.append(metadata)
		}) )

#if canImport(AdAstraBridgingByMask)
  // UIApplication.presentAlert(alertController)
#else
	let rootViewController = UIApplication.shared.windows.first?.rootViewController
	rootViewController?.present(alertController, animated: true, completion: { })
#endif

#endif

}
