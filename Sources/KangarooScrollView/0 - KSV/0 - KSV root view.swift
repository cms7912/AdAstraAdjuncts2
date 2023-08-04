//
//  File.swift
//
//
//  Created by cms on 12/31/21.
//

import Foundation
import SwiftUI
import Combine
import os.log
import AdAstraExtensions
import AdAstraBridgingByShim

#if DEBUG
// internal var KSVDebugMode: Bool = true
internal var KSVDebugMode: Bool = false
// let DebugDrawNotchAndDivotPositions: Bool = true
var DebugDrawNotchAndDivotPositions: Bool = KSVDebugMode

#else
internal let KSVDebugMode: Bool = false
let DebugDrawNotchAndDivotPositions: Bool = false

#endif

public typealias KSVPublishedSize = Published<CGSize?>.Publisher?
public typealias KSVExtendedScrollSizes = (underScroll: KSVPublishedSize, overScroll: KSVPublishedSize)

// var KSVLLogOnlyScrollViewName: String?
var KSVLLogOnlyScrollViewName: String? = "HighlightDrawer"
// var KSVLLogOnlyScrollViewName: String? = "DrawerTray-L0-NilIsRoot"
// var KSVLLogOnlyScrollViewName: String? // = "DrawerTray-L1-Code 1"
// var KSVLLogOnlyScrollViewName: String? = ""



public struct KangarooScrollView<Content: View>: View {
  public var llogPrefix = "🦘"
  public lazy var llogIsEnabled: Bool = KSVScrollManager.LLogIsEnabled(for: scrollViewName)

  public init(
    // for KSVScrollManager:
    direction: Binding<Axis.Set>,
    KangarooMapArray: Binding<[any Map]> = .constant([any Map]()),
    selectedMapIndex: Binding<Int?> = .constant(0),
    selectedNotchIndex: Binding<Int?> = .constant(0),
    selectedDivotIndex: Binding<Int?> = .constant(0),
    stablizeResizings: Binding<Bool> = .constant(true),
    snapToStopsEnabled: Binding<Bool> = .constant(true),
    scrollStatusDelegate: KSV_ScrollingStatusDelegate? = nil,
    gesturesBackgroundDestinationDelegate: Binding<UINSView?> = .constant(nil),


    // for platform-specific View:
    scrollable: Binding<Bool> = .constant(true),
    showsIndicators: Binding<Bool> = .constant(false),
    underScrollOverScrollPercentage: (CGFloat?, CGFloat?) = (nil, nil), // as percentage
    // underScrollOverScrollLength: (CGFloat, CGFloat) = (0, 0), // as length
    underScrollOverScrollPublishedSizes: KSVExtendedScrollSizes = (nil, nil),
    underScrollOverScrollColor: (Color, Color) = (Color.clear, Color.clear),
    debugMode: Bool = false,
    scrollViewName: String? = nil,

    wrappedContent: @escaping (KangarooScrollViewProxy) -> Content
  ) {
    _ksvScrollManager = StateObject(wrappedValue: KSVScrollManager(
      direction,
      KangarooMapArray,
      selectedNotchIndex,
      selectedDivotIndex,
      selectedMapIndex,
      stablizeResizings,
      snapToStopsEnabled,
      scrollStatusDelegate,
      gesturesBackgroundDestinationDelegate,
      true, // usePaneResizingCompletedDetection
      scrollViewName
    ))
    /*
     want to keep KangarooScrollView.init() clean with optional bindings for notch, divot, map indexes (some uses won't specify one or more of them—-that's fine, default .init() values of zero will be used.), so using three bindings instead of an awkward 'Stoplight()' leaking outside of KSV implementation (plus, the stoplight would need monitored for changes outside anyway). The indexes are optional because if no notch-divot pairing is found, then no stoplight exists, which 'willSet' the indexes to nil. This is a normal and valid state.
     */

    _genericViewModel = StateObject(wrappedValue: KangarooScrollViewGenericViewModel(
      direction,
      scrollable,
      stablizeResizings,
      showsIndicators,
      underScrollOverScrollPercentage,
      underScrollOverScrollPublishedSizes,
      underScrollOverScrollColor,
      scrollViewName
    ))

    self.wrappedContent = wrappedContent

    self.scrollViewName = scrollViewName

    #if DEBUG
    // KSVDebugMode = debugMode
    if debugMode { }
    if KSVDebugMode {
      // KSVDebug_AnchorSize = 5
    }
    #endif

    llogPrefix = "🦘\(scrollViewName ?? "")"
  } // END INIT()
  var scrollViewName: String?

  @StateObject var ksvScrollManager: KSVScrollManager
  @StateObject var genericViewModel: KangarooScrollViewGenericViewModel

  // var direction: Axis.Set { ksvScrollManager.direction }

  var wrappedContent: (KangarooScrollViewProxy) -> Content


  public var body: some View {
    KangarooScrollViewOnPlatform(wrappedContent: wrappedContent)
      .environmentObject(ksvScrollManager)
      .environmentObject(genericViewModel)
      .overlay(Group{ if ksvScrollManager.llogIsEnabled {
        VStack{
          Text("🪟: \(ksvScrollManager.paneLength.dd)")
          Text("🛌: \(ksvScrollManager.rawContentRect.dd)")
          Text("🥩: \(ksvScrollManager.rawContentOffset.dd)")
          Text("Δ: \(ksvScrollManager.deltaShift.dd)")
          Text("📍: \(ksvScrollManager.selectedStoplight?.notchPosition.dd ?? "")")
          Text("⛳️: \(ksvScrollManager.selectedStoplight?.divotPosition.dd ?? "")")
          Text("📍🛌: \(ksvScrollManager.notchPositionInContentFrame.dd ?? "")")
          Text("👇: \(ksvScrollManager.interactiveScrollingInProgress.description)")
          Text("🏹: \(ksvScrollManager.snapScrollingInProgress.description)")
          Text("⛽️: \(ksvScrollManager.stationedScroll.description)")
        }
        .font(.caption2)
        .background(Color.gray.opacity(0.50))
      } else { EmptyView() } })
  }
}

