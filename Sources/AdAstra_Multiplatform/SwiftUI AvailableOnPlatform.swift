//
//  File.swift
//
//
//  Created by cms on 12/20/21.
//

import Foundation
import SwiftUI
import AdAstraExtensions

// import AdAstraBridgingByShim
// import AdAstraBridgingNSExtensions

/*
 public struct InterfaceIdioms: OptionSet {
   static let iOS = InterfaceIdioms(rawValue: 1)
   static let macOS = InterfaceIdioms(rawValue: 1 << 1)
   // static let weeklyDigest = InterfaceIdioms(rawValue: 1 << 2)
   // static let newFollows = InterfaceIdioms(rawValue: 1 << 3)
     static let all: InterfaceIdioms = [.iOS, .macOS]
     public let rawValue: Int8
 }

 extension View {
     @ViewBuilder public func availableOnlyOn(idioms: [InterfaceIdioms]) -> some View {
 #if os(iOS)
         AvailableOnlyOn(content: self)
 #elseif os(macOS)
         AvailableOnlyOn(content: self)
 #else
         self
 #endif
     }
 }
 public struct AvailableOnlyOn<Content: View> {
     let content: Content
     @ViewBuilder public func lineSpacing(_ spacing: CGFloat) -> some View {
         content
             .lineSpacing(spacing)
     }
 }
 */

public extension View {
  func ifiOSOnly<Content: View>(transform: (Self) -> Content) -> some View {
    #if os(iOS)
    transform(self)
    #elseif os(macOS)
    self
    #endif
  }

  /* usage:
   .ifiOSOnly{view
   view.modifier()
   }
   */
  func ifmacOSOnly<Content: View>(transform: (Self) -> Content) -> some View {
    #if os(iOS)
    self
    #elseif os(macOS)
    transform(self)
    #endif
  }



  // public func contentTransitionWhenAvailable(_ transition: ContentTransition) -> some View {
  //   if #available(iOS 16, macOS 13.0, *) {
  //        // return self.contentTransition(transition)
  //      return self
  //   } else {
  //     return self
  //   }
  // }

  // public func draggableWhenAvailable(_ value: Transferable) -> some View {
  //   if #available(iOS 16, macOS 13.0, *) {
  //     return self.draggable(value)
  //   } else {
  //     return self
  //   }
  //
  // }
}

//import AdAstraBridgingNSExtensions

public extension NavigationView {
  func stackOrColumnsByHorizontalSizeClass(_ sizeClass: SwiftUI.UserInterfaceSizeClass) -> some View {
    Group {
      if sizeClass.isRegular {
        if #available(macOS 12.0, iOS 15.0, *) {
          self.navigationViewStyle(.columns)
        } else {
          self.navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
      } else if sizeClass.isCompact {
        #if os(iOS)
        self.navigationViewStyle(StackNavigationViewStyle())
        #else
        self // .compact in macOS does not happen
        #endif
      } else {
        self
      }
    }
  }
}


#if os(iOS)
public extension View {
  @ViewBuilder func hoverEffectiOSOnly(_ effect: HoverEffect = .automatic) -> some View {
    hoverEffect(effect)
  }

  @ViewBuilder func focusablemacOSOnly(_: Bool = false) -> some View {
    self
  }
}
#else
public enum HoverEffect {
  public static let automatic: HoverEffect? = nil
  public static let highlight: HoverEffect? = nil
  public static let lift: HoverEffect? = nil
}

@available(macOS 12.0, *)
public extension ContentShapeKinds {
  static let hoverEffect: ContentShapeKinds = .dragPreview
}

public extension View {
  @ViewBuilder func hoverEffectiOSOnly(_: HoverEffect? = nil) -> some View {
    self
  }

  @ViewBuilder func focusablemacOSOnly(_ bool: Bool) -> some View {
    focusable(bool)
  }
}
#endif
