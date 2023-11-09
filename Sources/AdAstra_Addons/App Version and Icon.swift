//
//  App Versions .swift
//  AdAstraAdjuncts
//
//  Created by cms on 10/22/21.
//

import Foundation
// import AdAstraBridgingByShim
import SwiftUI

#if os(iOS)
import UIKit
fileprivate typealias UINSApplication = UIApplication
typealias UINSImage = UIImage
#elseif os(macOS)
import AppKit
fileprivate typealias UINSApplication = NSApplication
typealias UINSImage = NSImage
#endif


extension UINSApplication {

	public static var appVersionShort: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
	// from: https://www.hackingwithswift.com/example-code/system/how-to-read-your-apps-version-from-your-infoplist-file
	public static var appVersionLong: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
	public static var appVersionShortAsDouble: Double { Double(appVersionShort)! }

}

@available(iOS, obsoleted: 14) // warnings start when this version is no longer equal or above deployment target build
public func WarnWheniOS13IsDropped() {}

@available(iOS, obsoleted: 15) // warnings start when this version is no longer equal or above deployment target build
public func WarnWheniOS14IsDropped() {}


// https://www.hackingwithswift.com/example-code/language/how-to-use-available-to-deprecate-old-apis



extension Bundle {
    var iconFileName: String {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return "" }
        return iconFileName ?? ""
    }
    
    
    var icon: UINSImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UINSImage(named: lastIcon)
        }
        return nil
    }
    
}

public struct AppIcon: View {

	public init(){

	}
// #if TARGET_OS_IOS
	
// #if !TARGET_OS_OSX
#if os(iOS)
	var iconImage: UIImage? = UIImage(named: Bundle.main.iconFileName)

  public var body: some View {
    if let iconImage = iconImage {
      Image(uiImage: iconImage)
    } else {
      EmptyView()
    }
  }
#else //if TARGET_OS_OSX //if TARGET_OS_IOS
	// #else
	var iconImage: NSImage? = NSImage(named: Bundle.main.iconFileName)

  public var body: some View {
    if let iconImage = iconImage {
      Image(nsImage: iconImage)
    } else {
      EmptyView()
    }
  }
#endif

		// https://stackoverflow.com/questions/62063972/how-do-i-include-ios-app-icon-image-within-the-app-itself
	

}


