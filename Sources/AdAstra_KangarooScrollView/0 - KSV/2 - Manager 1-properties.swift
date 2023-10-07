//
//  File.swift
//
//
//  Created by cms on 3/8/22.
//

import Foundation
import AdAstraExtensions
import SwiftUI
import Combine
import AdAstraBridgingByShim
import AALogger

public protocol KSVScrollVCDelegate: AnyObject {
  // associated type Content: View
  func move(by deltaShift: CGFloat)
  var theScrollView: KSV_ScrollView { get }
}


public class KangarooScrollViewGenericViewModel: ObservableObject, LLogHandling {
  public lazy var llogPrefix = "🦘\(scrollViewName ?? "") "
  public lazy var llogIsEnabled: Bool = KSVScrollManager.LLogIsEnabled(for: scrollViewName)

  init(
    _ direction: Binding<Axis.Set>,
    _ scrollable: Binding<Bool>,
    _ stablizeResizings: Binding<Bool> = .constant(true),
    _ showsIndicators: Binding<Bool>,
    _ underScrollOverScrollPercentage: (CGFloat?, CGFloat?),
    _ underScrollOverScrollPublishedSizes: KSVExtendedScrollSizes,
    _ underScrollOverScrollColor: (Color, Color),
    _ scrollViewName: String?
  ) {
    _direction = direction
    _scrollable = scrollable
    _stablizeResizings = stablizeResizings
    _showsIndicators = showsIndicators
    self.underScrollOverScrollPercentage = underScrollOverScrollPercentage
    self.underScrollOverScrollPublishedSizes = underScrollOverScrollPublishedSizes
    self.underScrollOverScrollColor = underScrollOverScrollColor
    self.scrollViewName = scrollViewName
  }

  @Binding var direction: Axis.Set
  @Binding var scrollable: Bool
  @Binding var stablizeResizings: Bool
  @Binding var showsIndicators: Bool
  var underScrollOverScrollPercentage: (CGFloat?, CGFloat?)
  var underScrollOverScrollPublishedSizes: KSVExtendedScrollSizes
  var underScrollOverScrollColor: (Color, Color)
  var scrollViewName: String?

  // Derived properties:
  var scrollableDirection: Axis.Set { scrollable ? direction : [] }
  // var underScrollLength: CGFloat { (ksvScrollManager.paneSize?.for(direction) * underScrollOverScroll.0) ?? 0 }
  // var overScrollLength: CGFloat { (ksvScrollManager.paneSize?.for(direction) * underScrollOverScroll.1) ?? 0 }

  // weak var ksvScrollManager: KSVScrollManager?
}

// public typealias KSVScrollManager = KSVScrollManager
public class KSVScrollManager: ObservableObjectWithLLogging, KSVScrollManagerInterface, LLogHandling {
  public lazy var llogPrefix = "🦘\(scrollViewName ?? "") "
  public var llogIsEnabled: Bool { Self.LLogIsEnabled(for: scrollViewName) }

  static func LLogIsEnabled(for scrollViewName: String?) -> Bool {
    guard KSVDebug.feature.logKangarooScrollView else { return false }
    if KSVLLogOnlyScrollViewName.isNil { return true }
    // let scrollViewNameComparison = scrollViewName == KSVLLogOnlyScrollViewName
    let scrollViewNameComparison = !(scrollViewName?.contains("DrawerTray") ?? true)
    return scrollViewNameComparison && KSVDebug.feature.logKangarooScrollView }

  public weak var scrollVCDelegate: KSVScrollVCDelegate? // this is KSV's embedded 'KSV_ScrollViewController' that manages the UIKit/AppKit scrolling. Used by KSVScrollManager to tell delegate '.move(by:)'.

  let PaneResizingCompletedSeconds = DispatchQueue.SchedulerTimeType.Stride.seconds(0.5)

  init(
    _ direction: Binding<Axis.Set>,
    _ KangarooMapArray: Binding<[any Map]>,
    _ currentNotchIndex: Binding<Int?>,
    _ currentDivotIndex: Binding<Int?>,
    _ currentMapIndex: Binding<Int?>,
    _ stablizeResizings: Binding<Bool> = .constant(true),
    _ snapToStopsEnabled: Binding<Bool>,
    _ scrollingStatusDelegate: KSV_ScrollingStatusDelegate?,
    _ gesturesBackgroundDestinationDelegate: Binding<UINSView?>,
    _ usePaneResizingCompletedDetection: Bool = true,
    _ scrollViewName: String? = nil
  ) {
    _direction = direction
    _kangarooMapArray = KangarooMapArray
    _currentNotchIndex = currentNotchIndex
    _currentDivotIndex = currentDivotIndex
    _currentMapIndex = currentMapIndex
    _snapToStopsEnabled = snapToStopsEnabled
    _stablizeResizings = stablizeResizings
    self.scrollingStatusDelegate = scrollingStatusDelegate
    _gesturesBackgroundDestinationDelegate = gesturesBackgroundDestinationDelegate
    self.scrollViewName = scrollViewName

    self.scrollingStatusDelegate?.ksvScrollManager = self

    for eachKangarooMap in KangarooMapArray.wrappedValue {
      eachKangarooMap.ksvScrollManager = self
    }

    if usePaneResizingCompletedDetection {
      // Setup Frame Resizing Detector:
      let paneResizedDetector = CurrentValueSubject<CGSize?, Never>(nil) // (CGSize(w: -1, h: -1))
      let paneResizedPublisher: AnyPublisher<CGSize?, Never> =
        paneResizedDetector
          // .dropFirst() //to drop the initial value CGSize(w: -1, h: -1)
          .debounce(for: PaneResizingCompletedSeconds, scheduler: DispatchQueue.main)
          .eraseToAnyPublisher()
      // .sink { [weak self] newSize in
      // 	self?.resizingPaneStopped(at: newSize)
      // }
      let paneResizedCancellable: AnyCancellable = paneResizedPublisher
        .sink { [weak self] newSize in
          self?.resizingPaneStopped(at: newSize)
        }

      self.paneResizedDetector = paneResizedDetector
      self.paneResizedPublisher = paneResizedPublisher
      self.paneResizedCancellable = paneResizedCancellable
    }
  } // end init()

  weak var ksvgvm: KangarooScrollViewGenericViewModel?

  @Binding var direction: Axis.Set
  @Binding var kangarooMapArray: [Map]
  @Binding var snapToStopsEnabled: Bool
  @Binding var stablizeResizings: Bool
  var scrollViewName: String?

  // @PublishedDelta var paneSize: CGSize? { willSet { objectWillChange.send() } }
  //  Frame Resizing:
  var paneResizedDetector: CurrentValueSubject<CGSize?, Never>?
  var paneResizedPublisher: AnyPublisher<CGSize?, Never>?
  var paneResizedCancellable: AnyCancellable?

  // @PublishedDelta var contentSize: CGSize?
  @PublishedDelta var contentLength: CGFloat?
  @PublishedDelta var rawContentRect: CGRect? { willSet {
    // objectWillChange.send()
  } didSet { llog("\(rawContentRect)") } } // raw means scrolling offset is negative
  // update contentSize first so only rawContentRect can trigger objectWillChange.send()

  @Binding public var currentNotchIndex: Int?
  @Binding public var currentDivotIndex: Int?
  @Binding public var currentMapIndex: Int?
  // these bindings currently only here for updating KSV's host as to the current status. Not (yet?) functional for KSV's host to change the value and have KSV update to that (except on first run).
  public var selectedStoplight: Stoplight?{
    willSet {
      llog("🚦\(newValue.dd)🚦")
      currentNotchIndex = newValue?.notchIndex
      currentDivotIndex = newValue?.divotIndex
      currentMapIndex = kangarooMapArray.firstIndex{$0.mapID == newValue?.map.mapID}
    }
  }

  func selectedStoplightSetup() {
    guard let map = kangarooMapArray[safeIndex: currentMapIndex],
          let notchIndex = currentNotchIndex,
          let divotIndex = currentDivotIndex else { return }
    selectedStoplight = Stoplight(map: map, notchIndex: notchIndex, divotIndex: divotIndex)
  }

  var currentMap: Map? { kangarooMapArray[safeIndex: currentMapIndex] }

  var notchDistanceOffCenter: CGFloat? { selectedStoplight?.notchPosition - paneCenterPoint }
  var notchPositionInContentFrame: CGFloat? { paneCenterInContent + notchDistanceOffCenter }
  public var deltaShift: CGFloat? {
    var delta = (selectedStoplight?.divotPosition - notchPositionInContentFrame)
    // #if os(macOS)
    //   if direction.isVertical {
    //     delta = delta * -1
    //   }
    // #endif
    return delta
  }

  // * Pane - Outer Window Frame *
  // var paneLength: CGFloat? { paneSize?.for(direction) }
  @PublishedDelta var paneLength: CGFloat?

  var paneCenterPoint: CGFloat? { paneLength / 2 }
  var paneCenterInContent: CGFloat? {
    return (rawContentOffset * -1) + paneCenterPoint
  }

  var resizingPaneInProgress: Bool = false {willSet{llog("\(newValue)")}}

  // * Content Frame *
  @Published var rawContentRectWhenLastStationary: CGRect? {
    willSet{
      llog("\(newValue)")

    }}

  var rawContentOffset: CGFloat? { rawContentRect?.origin.for(direction) }

  var paneCenterInContentWhenLastStationary: CGFloat?
  var paneCenterInContentAsRatioWhenLastStationary: CGFloat? {
    guard let paneCenterInContentWhenLastStationary = paneCenterInContentWhenLastStationary,
          let rawContentRectWhenLastStationary = rawContentRectWhenLastStationary
    else { return nil }
    return
      paneCenterInContentWhenLastStationary / rawContentRectWhenLastStationary.size.for(direction)
  }

  var contentAtFrontEdgeWhenLastStationary: Bool = false
  var contentAtBackEdgeWhenLastStationary: Bool = false

  // @State var contentSize: CGRect = .zero //
  // var contentLength: CGFloat? { rawContentRect?.size.for(direction) }


  // Setup completion
  var paneSetupDone: Bool = false
  var contentSetupDone: Bool = false
  var initialSetupDone: Bool = false






  var clientRequestedStableScroll: Bool = false
  // var scrollingInProgress: Bool { scrollingInProgressEphemiral || scrollingInProgressLocked }
  // var scrollingInProgressEphemiral: Bool = false {willSet{llog("\(newValue)")}}
  // var scrollingInProgressLocked: Bool = false {willSet{llog("\(newValue)")}}
  // var snapScrollingInProgress: Bool = false {willSet{llog("\(newValue)")}}
  var snapScrollingRetryInProgress: Bool = false {willSet{llog("\(newValue)")}}
  // var scrollingAtRest: Bool { scrollingInProgress.isFalse && snapScrollingInProgress.isFalse }

  // @Binding var scrollInteractivelyInProgress: Bool
  // @Binding var scrollSnappingInProgress: Bool
  // @Binding var scrollAtRest: Bool


  var interactiveScrollingInProgress: Bool = false
  var snapScrollingInProgress: Bool = false
  var stationedScroll: Bool = true // if interactive & snap scrolling false, this is true

  func updateScrolling(interactive: Bool, snap: Bool, stationed: Bool) {
    llog("👇interactive:\(interactive)  🏹snap:\(snap)  ⛽️stationed:\(stationed)")
    interactiveScrollingInProgress = interactive
    snapScrollingInProgress = snap
    stationedScroll = (snap || interactive).isFalse
    assert(stationed == stationedScroll)

    scrollingStatusDelegate?.interactiveScrollingInProgress = interactive
    scrollingStatusDelegate?.snapScrollingInProgress = snap
    scrollingStatusDelegate?.stationedScroll = stationed
  }

  var scrollingStatusDelegate: KSV_ScrollingStatusDelegate?
  @Binding var gesturesBackgroundDestinationDelegate: UINSView?
  // weak var scrollVC: KSV_ScrollViewControllerProtocol?

  public func snapTo(_ mapIndex: Int, _ notchIndex: Int, _ divotIndex: Int) {
    llog("using map index")
    snapTo(kangarooMapArray[safeIndex: mapIndex], notchIndex, divotIndex)
  }

  public func snapTo(_ map: Map?, _ notchIndex: Int, _ divotIndex: Int) {
    llog("using map object")
    guard let map = map else { return }
    updateScrolling(interactive: false, snap: true, stationed: false)
    selectedStoplight = Stoplight(map: map, notchIndex: notchIndex, divotIndex: divotIndex)
    snapToSelectedStop()
  }
}

public protocol KSV_ScrollingStatusDelegate {
  var interactiveScrollingInProgress: Bool { get set }
  var snapScrollingInProgress: Bool { get set }
  var stationedScroll: Bool { get set }
  var ksvScrollManager: KSVScrollManager? { get set }
  var parentKSVScrollManager: KSVScrollManager? { get }
}

extension KSV_ScrollingStatusDelegate {
  // var interactiveScrollingInProgress: Bool {get{
  //   false} set{}}
  // var snapScrollingInProgress: Bool {get{
  //   false} set{}}
  // var stationedScroll: Bool {get{
  //   false} set{}}
  // var ksvScrollManager: KSVScrollManager? { get{
  //   nil} set{} }
  // var parentKSVScrollManager: KSVScrollManager? { get{
  //   nil} }
}

public protocol KSVScrollManagerInterface: AnyObject {
  func snapTo(_ mapIndex: Int, _ notchIndex: Int, _ divotIndex: Int)
  func snapTo(_ map: Map?, _ notchIndex: Int, _ divotIndex: Int)
}











