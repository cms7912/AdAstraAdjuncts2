//
//  File.swift
//  File
//
//  Created by cms on 10/19/21.
//

import Foundation
import SwiftUI

public struct AvailableiOS15<Content: View> {
  let content: Content
  @ViewBuilder public func symbolRenderingMode(_ symbolRenderingMode: String) -> some View {
    if #available(iOS 15, macOS 12.0, *),
       symbolRenderingMode == ".hierarchical" {
      content
        .symbolRenderingMode(.hierarchical)
    } else {
      content
    }
  }
  
  
  @ViewBuilder public func swipeActions<Content>(edge: String = ".trailing", allowsFullSwipe: Bool = false, swipeContent: () -> Content ) -> some View where Content : View {
    if #available(iOS 15, macOS 12.0, *) {
      content
        .swipeActions(edge: edge == ".leading" ? .leading : .trailing
                      , allowsFullSwipe: allowsFullSwipe
                      , content: swipeContent )
    } else {
      content
    }
  }
  
  @ViewBuilder public func tint(_ color: Color) -> some View {
    if #available(iOS 15, macOS 12.0, *) {
      content
        .tint(color)
    } else {
      content
    }
  }
  
  
  @ViewBuilder public func listRowSeparator(_ visibility: String) -> some View {
    // 'listRowSeparator(_:edges:)' is unavailable in macOS
    if #available(iOS 15, *) {
      content
#if !os(macOS)
      
        .listRowSeparator(visibility==".hidden" ? .hidden : .automatic )
#endif
    } else {
      content
    }
  }
  
  @ViewBuilder public func searchable(
    searchQuery: Binding<String>,
    placement: String = ".automatic",
    prompt: String ) -> some View {
    
    if #available(iOS 15, macOS 12.0, *) {
      // 'navigationBarDrawer(displayMode:)' is unavailable in macOS
      content
        .searchable(text: searchQuery, placement:
                      
                      {
#if os(iOS)
          if placement == ".automatic" {
            // .navigationBarDrawer(displayMode: SearchFieldPlacement.automatic)
            return SearchFieldPlacement.automatic
          } else {
            // .navigationBarDrawer(displayMode: SearchFieldPlacement.always)
            return SearchFieldPlacement.automatic
          }
#elseif os(macOS)
          return SearchFieldPlacement.automatic
#endif
          
        }()
                    
        )
      
    } else {
      content
    }
  }
  
  @ViewBuilder public func background(_ style: Color, ignoresSafeAreaEdges: Edge.Set) -> some View {
    if #available(iOS 15, macOS 12.0, *) {
      content
        .background(style, ignoresSafeAreaEdges: ignoresSafeAreaEdges)
    } else {
      content
        .background(style)
    }
  }
  
  @ViewBuilder
  public func overlay2<OverlayContent>(_ alignment: Alignment = .center, overlayContent: () -> OverlayContent) -> some View where OverlayContent : View {
    if #available(iOS 15.0, macOS 12.0, *) {
      content
        .overlay(alignment: alignment, content: overlayContent)
    } else {
      content
        .overlay(
          ZStack(alignment: alignment) {
            Color.clear
            overlayContent()
          }
        )
    }
  }
  @ViewBuilder
  public func contentShapeForHoverEffect<S>(_ shape: S) -> some View where S: Shape {
    if #available(iOS 15.0, macCatalyst 12.0, *) {
      content
//        .contentShape(.hoverEffect, shape)
    } else {
      content
    }
  }


  
  // @ViewBuilder public func Do<Content>(newerModifiers: (View) -> Content) -> some View where Content : View {
  //   if #available(iOS 15, macOS 12.0, *) {
  //     newerModifiers(content)
  //   } else {
  //     content
  //   }
  //   
  // }

  // https://davedelong.com/blog/2021/10/09/simplifying-backwards-compatibility-in-swift/
}

extension View {
  public var availableiOS15: AvailableiOS15<Self> { AvailableiOS15(content: self) }
  public var PlatformiOS15orMacOS12OrHigher: Bool {
		if #available(iOS 15, macOS 12.0, *) { return true } else { return false }
	}
}


