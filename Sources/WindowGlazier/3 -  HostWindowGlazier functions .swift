//
//  File.swift
//  
//
//  Created by cms on 2/6/22.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



// ** Showing Windows **

public extension HostWindowGlazier {
  /*
   scheme://domain/path/to/?queryName=queryValue
   
   scheme: "caleoAppWindows"
   host: "[GlazierWindowType.rawValue]"
   path: ""
   queryItems: [String:String?]
   */
  
  static func show(_ windowType: String){
    guard let eventRequest = GlazierExternalEventRequest(windowType: windowType) else {
      print("failed to construct SubwayWindowType windowURL"); return
    }
    Self.openOrMoveToFront(eventRequest.eventURL)
  }
  
  static func show(_ windowType: String, _ appWindowID: String?){
    
    // prepare 'appWindowID' as a url query item
    var queryDictionary = [String : String?]()
    queryDictionary.updateValue(appWindowID, forKey: GlazierExternalEventRequest.AppWindowIDName)
    
    let eventRequest =
    GlazierExternalEventRequest(
      windowType: windowType,
      queryDictionary: queryDictionary)
    
    guard let windowURL = eventRequest?.eventURL else { print("failed to construct SubwayWindowType windowURL"); return }
    Self.openOrMoveToFront(windowURL)
  }
  

	private static func openOrMoveToFront(_ windowURL: URL) {
    guard let newRequest = GlazierExternalEventRequest(windowURL) else {
      print("failed to generate GlazierExternalEventRequest from windowURL: \(windowURL)")
      return }
    self.openOrMoveToFront(newRequest)
  }
  
  private static func openOrMoveToFront(_ newRequest: GlazierExternalEventRequest) {
    
    var foundGlaziers: [HostWindowGlazier] = [HostWindowGlazier]()
    foundGlaziers = HostWindowGlazier.ExistingGlaziers.filter{$0.externalEventRequest?.windowSpecificID == newRequest.windowSpecificID } // don't compare just 'externalEventRequest', because either request could have additional query parameters missing in the other. Instead use 'windowSpecificID'
    

    if foundGlaziers.isEmpty {
      // no window exists. Open a new one.
      NSWorkspace.shared.open(newRequest.eventURL)
      // HostWindowGlazier.ExistingHostWindows[newID]?.window?.center()
		} else {
			//move any existing window(s) to front
			foundGlaziers.forEach{ $0.bringToFront() }

		}
  }
  // https://developer.apple.com/forums/thread/651592}
 
  func bringToFront(){
		windowReference?.makeKeyAndOrderFront(nil)
  }

}


