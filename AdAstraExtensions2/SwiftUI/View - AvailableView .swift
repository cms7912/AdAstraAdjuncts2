//
//  File.swift
//  
//
//  Created by cms on 9/5/22.
//

import Foundation
import SwiftUI



public protocol ViewWithAvailableAbstract {
  
  associatedtype MContent: View
  associatedtype TContent: View
  // associatedtype AContent: View
  associatedtype WContent: View


  @available(iOS 16, macOS 13, *)
  var bodyForiOS16macOS13: MContent { get }
  
  var bodyTraditional: TContent { get }

	var bodyWrapper: WContent { get }
}
public extension ViewWithAvailableAbstract {
  var bodyAvailable: some View {
    Group{
      if #available(iOS 16, macOS 13, *){
        bodyForiOS16macOS13
      }
      if #unavailable(iOS 16, macOS 13){
        bodyTraditional
      }
    }
  }
	var bodyWrapper: some View {
		bodyAvailable
	}

	// var body: some View {
	// 	bodyWrapper
	// }

}
public protocol ViewWithAvailable: ViewWithAvailableAbstract, View {
// public protocol ViewWithAvailable: View {
	// associatedtype WContent: View
	// var bodyWrapper: WContent { get }

}; public extension ViewWithAvailable {
	var body: some View {
		bodyWrapper
	}
}



extension View {
  
  // public func modifiersForiOS16macOS13<Content: View>(modifier: (Self) -> Content) -> some View {
  //   Group{
  //     if #available(iOS 16, macOS 13, *){
  //       modifier(self)
  //     }
  //     if #unavailable(iOS 16, macOS 13){
  //       self
  //     }
  //   }
  // }
  // /* usage:
  //  .ifiOSOnly{view
  //  view.modifier()
  //  }
  //  */
  // public func modifiersForTraditional<Content: View>(modifier: (Self) -> Content) -> some View {
  //   Group{
  //     if #available(iOS 16, macOS 13, *){
  //       self
  //     }
  //     if #unavailable(iOS 16, macOS 13){
  //       modifier(self)
  //     }
  //   }
  // }
  
  public func modifiersFor<Content: View >(modifier: (Self) -> Content) -> some View {
        modifier(self)
  }
  /* usage:
   .modifiersFor{view in Group{
     if #available(iOS 16.0, macOS 13.0, *) {
       view
         .bold(DebugBordersViewModel.AllBordersHidden.isOff)
     } else {
       view
     }
   } }
   */
}
  







