//
//  File.swift
//  
//
//  Created by cms on 2/6/22.
//

import Foundation


public struct GlazierExternalEventRequest: Equatable {
	// enum QueryName: String {
		// case projectID
		// case test
	// }

	static let AppWindowIDName: String = "appWindowID"

	init?(_ url: URL?){

		// var projectID: String?

		guard let originatingEventURL = url else { return nil }

		guard let components = URLComponents(url: originatingEventURL, resolvingAgainstBaseURL: false) else { return nil }
		//       https://www.avanderlee.com/swift/url-components/

		guard let windowType: String = components.host else { return nil }

		guard HostWindowGlazier.AppProvidedWindowTypeStrings.contains(windowType) else { return nil }

		let queryItems = components.queryItems ?? [URLQueryItem]()
		var queryDictionary: [String:String?] = [String:String?]()
		queryItems.forEach{ queryDictionary.updateValue($0.value, forKey: $0.name) }

		// if windowType == .project,
		//    let foundID = queryDictionary[QueryName.projectID.rawValue] {
		//   projectID = foundID
		// }

		self.eventURL = originatingEventURL
		self.eventURLComponents = components
		self.windowType = windowType
		self.queryDictionary = queryDictionary
		self.windowSpecificID = windowType + ((queryDictionary[Self.AppWindowIDName] ?? "") ?? "")
	}

	public let eventURL: URL
	let eventURLComponents: URLComponents
	let windowType: String
	let queryDictionary: [String:String?]
	let windowSpecificID: String // used to compare whether eventRequest is for an existing window, regardless of whether queryItems are different between them

	init?(windowType: String, queryDictionary: [String:String?] = [String:String?]()){
		guard HostWindowGlazier.VerifyWindowType(windowType) else { return nil }

		var compositeURL = URLComponents()
		compositeURL.scheme = HostWindowGlazier.AppProvidedURLScheme
		compositeURL.host = windowType
		compositeURL.queryItems = queryDictionary.map{ URLQueryItem(name: $0, value: $1) }

		self.init(compositeURL.url)
	}
}
