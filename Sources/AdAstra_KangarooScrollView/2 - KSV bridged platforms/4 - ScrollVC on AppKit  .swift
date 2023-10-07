//
//  File.swift
//
//
//  Created by cms on 3/12/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions

#if os(macOS)
import AppKit

protocol KSV_ScrollViewControllerProtocol: AnyObject {
  // var scrollView: KSV_ScrollView { get set } // 'set' needed?
}

class InvisibleScroller: NSScroller {
  override class var isCompatibleWithOverlayScrollers: Bool {
    return true
  }

  override class func scrollerWidth(for _: NSControl.ControlSize, scrollerStyle _: NSScroller.Style) -> CGFloat {
    return CGFloat.leastNormalMagnitude // Dimension of scroller is equal to `FLT_MIN`
  }

  override public init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }

  private func setupUI() {
    // Below assignments not really needed, but why not.
    scrollerStyle = .overlay
    alphaValue = 0
  }
  // https://stackoverflow.com/questions/9364953/hide-scrollers-while-leaving-scrolling-itself-enabled-in-nsscrollview
}

class KSV_PlatformScrollViewController<Content: View>: KSV_UniversalPrefixScrollViewController<Content>, KSV_ScrollViewControllerProtocol {
  var lastPaneSize: CGSize?
  var animationCancelled: Bool = false

  override func viewDidAppear() {
    super.viewDidAppear()
    universalViewDidAppear() } // √

  override func platformSetupScrollView(_ newScrollView: inout KSV_ScrollView) { extendedPlatformSetupScrollView(&newScrollView) }
}

extension KSV_PlatformScrollViewController {
  // func setup(_  docStackView: inout KSV_StackView) {
  // 	docStackView.orientation = directionStackOrientation
  // }

  func extendedPlatformSetupScrollView(_ newScrollView: inout KSV_ScrollView) {
    newScrollView.hasHorizontalScroller = ksvScrollManager.direction.isHorizontal
    newScrollView.hasVerticalScroller = ksvScrollManager.direction.isVertical
    if gvm.showsIndicators.isFalse {
      newScrollView.horizontalScroller = InvisibleScroller()
      newScrollView.verticalScroller = InvisibleScroller()
    }

    newScrollView.drawsBackground = false
    // newScrollView.backgroundColor = .clear
    // newScrollView.drawsBackground = true

    // newScrollView.documentView?.scroll(.zero)
  }

  func platformViewDidLoad() {
    // 1) insert docStackView into scrollView
    theScrollView.documentView = documentView
    // scrollView.documentView?.addSubviewWithAnchorConstraints(docStackView)

    let clipView = // NSClipView()
      theScrollView.contentView // = clipView
    clipView.translatesAutoresizingMaskIntoConstraints = false
    theScrollView.addConstraints([
      NSLayoutConstraint(
        item: theScrollView, attribute: .leading,
        relatedBy: .equal,
        toItem: clipView, attribute: .leading,
        multiplier: 1, constant: 0
      ),
      NSLayoutConstraint(
        item: theScrollView, attribute: .trailing,
        relatedBy: .equal,
        toItem: clipView, attribute: .trailing,
        multiplier: 1, constant: 0
      ),
      NSLayoutConstraint(
        item: theScrollView, attribute: .top,
        relatedBy: .equal,
        toItem: clipView, attribute: .top,
        multiplier: 1, constant: 0
      ),
      NSLayoutConstraint(
        item: theScrollView, attribute: .bottom,
        relatedBy: .equal,
        toItem: clipView, attribute: .bottom,
        multiplier: 1, constant: 0
      ),
    ])




    // clipView.addSubview(documentView)

    // Add Front Constraint
    theScrollView.addConstraint(
      NSLayoutConstraint(
        item: clipView, attribute: directionOrientationFront,
        relatedBy: .equal,
        toItem: documentView, attribute: directionOrientationFront,
        multiplier: 1, constant: 0
      ))

    // Add Side Constraints
    for sideDirection in [directionCounterOrientationFront, directionCounterOrientationBack] {
      theScrollView.addConstraint(
        NSLayoutConstraint(
          item: clipView, attribute: sideDirection,
          relatedBy: .equal,
          toItem: documentView, attribute: sideDirection,
          multiplier: 1, constant: 0
        )) }

    // // Add Back Constraint
    // scrollView.addConstraint(
    // 	NSLayoutConstraint(
    // 		item: clipView, attribute: directionOrientationBack,
    // 		relatedBy: .equal,
    // 		toItem: documentView, attribute: directionOrientationBack,
    // 		multiplier: 1, constant: 0))


    // 2) Set backgroundColor
    underScrollView.layer?.backgroundColor = underScrollViewBackgroundColor.cgColor
    underScrollView.backgroundColor = NSColor(underScrollViewBackgroundColor)
    // underScrollView.layer?.backgroundColor = NSColor.red.withAlphaComponent(0.20).cgColor
    // underScrollView.backgroundColor = NSColor.blue.withAlphaComponent(0.20)
    overScrollView.layer?.backgroundColor = overScrollViewBackgroundColor.cgColor
    overScrollView.backgroundColor = NSColor(overScrollViewBackgroundColor)
    // setting backgroundColor here because .layer optionality differs between platforms

    // 3) Add scroll tracking
    addNotificationObservers()
  }


  func platformMove(by _: CGFloat) {
    llog("will move from: rawDocumentFrame: \(rawDocumentFrame.origin)")
    guard let deltaShift = ksvScrollManager.deltaShift else { return }
    var deltaShiftAsPoint = CGPoint(ksvScrollManager.direction, deltaShift, oppositeDimensionSize: 0)
    let newOrigin = (theScrollView.contentView.bounds.origin + deltaShiftAsPoint) // + to flip axis for macOS

    animationCancelled = false
    NSAnimationContext.beginGrouping() // create the animation
    NSAnimationContext.current.duration = 0.6 // set its duration
    // set the new origin with animation
    NSAnimationContext.current.completionHandler = ({ [weak self] in
      guard let self = self else { return }
      guard self.animationCancelled.isFalse else { return }
      // self.ksvScrollManager.endSnapScroll()
      // self.ksvScrollManager.updateTrackingContentFrame(with: self.rawDocumentFrame) // for good measure
      self.ksvScrollManager.scrollEnded(at: self.rawDocumentFrame)
      self.llog("did move to: rawDocumentFrame: \(self.rawDocumentFrame.origin)")
    })
    theScrollView.contentView.animator().setBoundsOrigin(newOrigin)
    theScrollView.reflectScrolledClipView(theScrollView.contentView) // and inform the scroll view about that
    NSAnimationContext.endGrouping() // finally do the animation
  }

  func reviseDragEndingAt(targetContentOffset _: UnsafeMutablePointer<CGPoint>) { }
}




class KSV_PlatformHostingController<Content>: NSHostingController<Content> where Content: View {
  override func viewDidLayout() {
    super.viewDidLayout()
    // self.view.invalidateIntrinsicContentSize()
    // 	//https://stackoverflow.com/questions/58399123/uihostingcontroller-should-expand-to-fit-contents
  }
}



class KSV_PlatformView: NSView {
  lazy var llogPrefix = "🦘\(ksvScrollManager?.scrollViewName ?? "") "

  public var llogIsEnabled: Bool { KSVScrollManager.LLogIsEnabled(for: ksvScrollManager?.scrollViewName) && KSVDebug.feature.logKangarooScrollView_ViewController }

  weak var wrappedContentView: KSV_WrappedContentView?
  weak var ksvScrollManager: KSVScrollManager?


  override var isFlipped: Bool { return true }

  override func hitTest(_ point: NSPoint) -> NSView? {
    ksv_HitTest(point)
  }

  func ksv_HitTest(_ point: NSPoint, _: NSEvent? = nil) -> NSView? {
    super.hitTest(point)
  }


  var DebugDrawNotchAndDivotPositionsOnAppKit: Bool { DebugDrawNotchAndDivotPositions }
  // how to add position text next to the lines
  // https://developer.apple.com/forums/thread/61511

  var ksvPositionsLayers: [CALayer] = .empty

  func ksvEraseOldPositions() {
    ksvPositionsLayers.forEach{
      $0.removeFromSuperlayer()
    }
    ksvPositionsLayers.removeAll()
  }

  func ksvDrawAllPositions() {
    ksvEraseOldPositions()
    // subclasses override this, call super.ksvDrawAllPositions() to get erasing, then draw their own positions.
  }

  func ksvDrawPosition(_ position: CGFloat?, _ color: NSColor = NSColor.systemRed, _ lineWidth: CGFloat = 2.0) {
    guard KSVDebugMode else { return }
    guard DebugDrawNotchAndDivotPositionsOnAppKit else { return }
    guard let position = position else {
      return
    }
    color.set()
    let figure = NSBezierPath()
    if ksvScrollManager?.direction.isVertical ?? true {
      figure.move(to: NSMakePoint(0, position))
      figure.line(to: NSMakePoint(frame.size.width, position))
    } else { // horizontal:
      figure.move(to: NSMakePoint(position, 0))
      figure.line(to: NSMakePoint(position, frame.size.height))
    }
    figure.lineWidth = lineWidth
    figure.stroke()


    needsDisplay = true
  }
}

class KSV_PlatformStageView: KSV_PlatformView {
  override func draw(_ dirtyRect: NSRect) {
    // override func draw(rect: CGRect){
    // super.draw(rect: rect)
    super.draw(dirtyRect)

    if let map = ksvScrollManager?.currentMap as? MapWithPositions {
      map.notchPositions.forEach{
        ksvDrawPosition($0, .systemBlue.withAlphaComponent(0.7), 3.0)
      }
    }
  }

  //	override var isFlipped: Bool { return true }
}

public class KSV_PlatformScrollView: NSScrollView {
  override public var isFlipped: Bool { return true }
  weak var ksvScrollManager: KSVScrollManager?
  var myParentScrollView: KSV_ScrollView? { nil }
  var myGrandparentScrollView: KSV_ScrollView? { nil }

  override public func scrollWheel(with event: NSEvent) {
    guard let ksvScrollManager = ksvScrollManager,
          let myParentScrollView = myParentScrollView
    else {
      super.scrollWheel(with: event)
      return
    }

    // Sometimes forward scrolls to parent/grandparent

    if event.type == .scrollWheel || event.type == .swipe {
      let eventDirection: Axis.Set = abs(event.scrollingDeltaX) >= abs(event.scrollingDeltaY) ? .horizontal : .vertical

      if eventDirection != ksvScrollManager.direction {
        // event direction is opposite scrollDirection forward the scroll event to parent ScrollVC
        myParentScrollView.scrollWheel(with: event)
        return

      } else if true { // ksvScrollManager.stationedScroll {
        // if not moving, then test if also at front/back edge & should pass event to grandparentScrollView

        let eventDeltaInScrollAxis =
          ksvScrollManager.direction.isHorizontal ? event.scrollingDeltaX : event.scrollingDeltaY
        // (will need to refactor to handle right-to-left language locales)

        if (ksvScrollManager.contentAtFrontEdgeWhenLastStationary && eventDeltaInScrollAxis > 0) ||
          (ksvScrollManager.contentAtBackEdgeWhenLastStationary && eventDeltaInScrollAxis < 0)
        {
          // at edge and scrolling away from that edge

          if let myGrandparentScrollView = myGrandparentScrollView {
            // if this scrollView has a grandparentScrollView that exists, then forward this event to that grandparentScrollView to handle scrolling. If no grandparentScrollView, then continue to handle locally as rubber banding effect.
            myGrandparentScrollView.scrollWheel(with: event)
            return
          }
        }
      }
    }
    super.scrollWheel(with: event)
    // 2022-04-13 -- This works!   The event gets passed up to parent KSVs and consumed
  }
}


class KSV_PlatformStackView: NSStackView {
  override var isFlipped: Bool { return true }
}

class KSV_PlatformDocumentView: KSV_PlatformView { }

class KSV_WrappedContentPlatformView: KSV_PlatformView {
  // override func draw(rect: CGRect){
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    ksvDrawPosition(ksvScrollManager?.notchPositionInContentFrame, .systemPurple.withAlphaComponent(0.5), 8.0)

    if let map = ksvScrollManager?.currentMap as? MapWithPositions {
      map.divotPositions.forEach{
        ksvDrawPosition($0, .systemRed, 2.0)
      }
    }
  }
}


extension NSView{
  func ksv_HitTestExternal(_ point: NSPoint, _: NSEvent? = nil) -> NSView? {
    hitTest(point)
  }
}
#endif
