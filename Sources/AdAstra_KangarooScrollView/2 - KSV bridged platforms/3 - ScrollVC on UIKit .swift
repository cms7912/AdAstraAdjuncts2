//
//  File.swift
//
//
//  Created by cms on 3/12/22.
//

import Foundation
import AdAstraExtensions
import SwiftUI

#if os(iOS)
import UIKit

// ----- UIKit -------
protocol KSV_ScrollViewControllerProtocol: UIScrollViewDelegate {
  var ksvScrollManager: KSVScrollManager { get }
  var rawDocumentFrame: CGRect { get }

  func platformMove(by deltaShift: CGFloat)
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)

  // var scrollView: KSV_ScrollView { get set } // set needed?
}

class KSV_PlatformScrollViewController<Content: View>: KSV_UniversalPrefixScrollViewController<Content>, KSV_ScrollViewControllerProtocol {
  override func platformSetupScrollView(_ newScrollView: inout KSV_ScrollView) { extendedPlatformSetupScrollView(&newScrollView) }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    universalViewDidAppear() } // √

  func scrollViewDidScroll(_: UIScrollView) {
    // self.updateTrackingContentFrame(scrollEnded: false)
    // this call sends updates on every move and does so after other calls using 'scrollEnded=true' ... thereby overriding the scrollEnded value and continues as an interactive scroll incorrectly.
  }

  func scrollViewWillEndDragging(_: UIScrollView,
                                 withVelocity _: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    updateTrackingContentFrameWith(targetContentOffset: targetContentOffset)
  }

  // KSV_ScrollViewControllerProtocol fulfillment:
  func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
    // self.updateTrackingContentFrame(scrollEnded: true)
    guard decelerate.isFalse else { return }
    updateTrackingContentFrame(scrollEnded: true)
  }

  func scrollViewWillBeginDecelerating(_: UIScrollView) {
    // self.updateTrackingContentFrame(scrollEnded: true)
  }

  func scrollViewDidEndDecelerating(_: UIScrollView) {
    updateTrackingContentFrame(scrollEnded: true)
  }

  func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
    updateTrackingContentFrame(scrollEnded: true)
  }
}

extension KSV_PlatformScrollViewController {
  func extendedPlatformSetupScrollView(_ newScrollView: inout KSV_ScrollView) {
    newScrollView.delegate = self
    // newScrollView.wrappedContentView = wrappedContentView
    newScrollView.bounces = true
    newScrollView.isDirectionalLockEnabled = true
    if ksvScrollManager.direction.isHorizontal {
      newScrollView.alwaysBounceVertical = false
      newScrollView.alwaysBounceHorizontal = true
    } else {
      newScrollView.alwaysBounceVertical = true
      newScrollView.alwaysBounceHorizontal = false
    }

    if gvm.showsIndicators.isFalse {
      newScrollView.showsVerticalScrollIndicator = false
      newScrollView.showsHorizontalScrollIndicator = false
    }
  }

  func platformViewDidLoad() {
    // 1) insert documentView into scrollView
    // theScrollView.addSubviewWithAnchorConstraints(documentView)


    // Find .bottom/.trailing constraint and set it to low priority
    // scrollView.constraints.forEach{c in
    // 	if c.firstAttribute == directionOrientationBack &&
    // 			c.secondAttribute == directionOrientationBack {
    // 		c.priority = UILayoutPriority(rawValue: 250)
    // 	}
    // }

    documentView.willMove(toSuperview: theScrollView)
    theScrollView.addSubview(documentView)
    documentView.didMoveToSuperview()


    theScrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: documentView.leadingAnchor).isActive = true
    theScrollView.contentLayoutGuide.topAnchor.constraint(equalTo: documentView.topAnchor).isActive = true
    theScrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: documentView.bottomAnchor).isActive = true
    theScrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: documentView.trailingAnchor).isActive = true

    // constrain subview to sides of dcumentView
    NSLayoutConstraint.activate([
      // NSLayoutConstraint(
      // 	item: scrollView.contentLayoutGuide,
      // 	attribute: directionConstraintAttribute,
      // 	relatedBy: .equal,
      // 	toItem: docStackView,
      // 	attribute: directionConstraintAttribute,
      // 	multiplier: 1,
      // 	constant: 0)
      // ,
      NSLayoutConstraint(
        // item: theScrollView.frameLayoutGuide,
        item: documentView,
        attribute: directionCounterConstraintAttribute,
        relatedBy: .equal,
        toItem: theScrollView.frameLayoutGuide,
        attribute: directionCounterConstraintAttribute,
        multiplier: 1,
        constant: 0
      ),

    ])


    // 2) Set backgroundColor
    //    underScrollView.layer.backgroundColor = underScrollViewBackgroundColor
    //  overScrollView.layer.backgroundColor = overScrollViewBackgroundColor
    underScrollView.backgroundColor = UIColor(underScrollViewBackgroundColor)
    overScrollView.backgroundColor = UIColor(overScrollViewBackgroundColor)

    // setting backgroundColor here because .layer optionality differs between platforms


    // 3) Add scroll tracking

    // Pane size changes:
    // self.ksvScrollManager.updateTrackingPaneSize(with: scrollView.frame.size)
    // self.ksvScrollManager.resizingPaneStopped(at: scrollView.frame.size)
    theScrollView.onResize = {_ in
      self.updateTrackingPaneSize()
    }

    // Content frame changes:
    documentView.onResize = {[weak self] _ in
      guard let self = self else { return }
      self.updateTrackingContentFrame()
    }
  }


  func platformMove(by _: CGFloat) {
    let DurationOfMoveAnimation: CGFloat = 0.8
    // llog("will move from: rawDocumentFrame: \(rawDocumentFrame.origin)")
    guard let deltaShift = ksvScrollManager.deltaShift else { return }
    let deltaShiftAsPoint = CGPoint(ksvScrollManager.direction, deltaShift, oppositeDimensionSize: 0)
    let newOrigin = (theScrollView.contentOffset + deltaShiftAsPoint)
    // let newOrigin = rawDocumentFrame.origin + deltaShiftAsPoint

    // theScrollView.setContentOffset(newOrigin, animated: true)
    UIView.animate(withDuration: DurationOfMoveAnimation,
                   animations: { [weak self] in
                     self?.theScrollView.contentOffset = newOrigin
                     // theScrollView.setContentOffset(newOrigin, animated: true)
                   }) { [weak self] _ in
      guard let self = self else { return }
      self.updateTrackingContentFrame(scrollEnded: true) // for good measure
      // self.llog("did move to: rawDocumentFrame: \(self.rawDocumentFrame.origin)")
    }
    // self.llog("did move to: rawDocumentFrame: \(self.rawDocumentFrame.origin)")
  }

  func updateTrackingContentFrameWith(targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    reviseDragEndingAt(targetContentOffset: targetContentOffset)
    wrappedContentView.ksvDrawAllPositions()
  }
}

extension KSV_PlatformScrollViewController {
  func reviseDragEndingAt(targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    ksvScrollManager.reviseDragEndingAt(targetOffset: targetContentOffset,
                                        currentOffset: theScrollView.contentOffset,
                                        currentRawDocumentFrame: rawDocumentFrame)
  }
}

class KSV_PlatformHostingController<Content>: UIHostingController<Content> where Content: View {
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    #if os(iOS)
    view.invalidateIntrinsicContentSize() // necessary for iOS to adapt the scrollView upon changes in contents size
    #endif
    // https://stackoverflow.com/questions/58399123/uihostingcontroller-should-expand-to-fit-contents
  }
}


class KSV_PlatformView: UIView{
  lazy var llogPrefix = "🦘\(ksvScrollManager?.scrollViewName ?? "") "

  public var llogIsEnabled: Bool { KSVScrollManager.LLogIsEnabled(for: ksvScrollManager?.scrollViewName) && KSVDebug.feature.logKangarooScrollView_ViewController }

  weak var wrappedContentView: KSV_WrappedContentView?
  weak var ksvScrollManager: KSVScrollManager?

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    ksv_HitTest(point, event)
  }

  func ksv_HitTest(_ point: CGPoint, _ event: UIEvent? = nil) -> UIView? {
    super.hitTest(point, with: event)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    ksvDrawAllPositions()
  }

  var DebugDrawNotchAndDivotPositionsOnUIKit: Bool { DebugDrawNotchAndDivotPositions }
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
  }

  func ksvDrawPosition(_ position: CGFloat?, _ color: UIColor = UIColor.systemRed, _ lineWidth: CGFloat = 2.0) {
    guard KSVDebugMode else { return }
    guard DebugDrawNotchAndDivotPositionsOnUIKit else { return }
    guard let position = position else {
      return
    }
    // color.set()

    let path = UIBezierPath()
    var textFrame: CGRect = .zero
    var textAlignment: CATextLayerAlignmentMode = .center

    if ksvScrollManager?.direction.isVertical ?? true {
      path.move(to: CGPoint(x: 0, y: position))
      path.addLine(to: CGPoint(x: frame.size.width, y: position))
      textFrame = CGRect(x: 0, y: position, width: 60, height: 20)
      textAlignment = .left
    } else { // horizontal:
      path.move(to: CGPoint(x: position, y: 0))
      path.addLine(to: CGPoint(x: position, y: frame.size.height))
      textFrame = CGRect(x: position, y: 0, width: 60, height: 20)
      textAlignment = .left
    }

    let textLayer = CATextLayer()
    textLayer.string = "\(position.dd)"
    textLayer.foregroundColor = UIColor.gray.cgColor
    textLayer.font = UIFont(name: "Avenir", size: 10.0)
    textLayer.fontSize = 10.0
    textLayer.alignmentMode = textAlignment
    textLayer.backgroundColor = UIColor.clear.cgColor
    textLayer.frame = textFrame
    textLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(textLayer)
    ksvPositionsLayers.append(textLayer)

    // design path in layer
    let positionLayer = CAShapeLayer()
    positionLayer.path = path.cgPath
    positionLayer.strokeColor = color.cgColor
    positionLayer.lineWidth = lineWidth


    // needsDisplay = true
    layer.addSublayer(positionLayer)
    ksvPositionsLayers.append(positionLayer)

    // adapted from: https://stackoverflow.com/questions/26662415/draw-a-line-with-uibezierpath
  }
}

class KSV_PlatformStageView: KSV_PlatformView { }

public class KSV_PlatformScrollView: UIScrollView {
  weak var ksvScrollManager: KSVScrollManager?
  var myParentScrollView: KSV_ScrollView? { nil }
  var myGrandparentScrollView: KSV_ScrollView? { nil }

  override public func layoutSubviews() {
    super.layoutSubviews()
    updateResize()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)
    updateResize()
  }

  private var lastFrame: CGRect?
  func updateResize() {
    guard frame != lastFrame else { return }
    lastFrame = frame
    onResize?(frame)
  }

  open var onResize: ((CGRect) -> Void)?
}

class KSV_PlatformStackView: UIStackView {
  var orientation: NSLayoutConstraint.Axis {
    set {
      self.axis = newValue
    }
    get {
      return self.axis
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateResize()
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    updateResize()
  }

  private var lastFrame: CGRect?
  func updateResize() {
    guard frame != lastFrame else { return }
    lastFrame = frame
    onResize?(frame)
  }

  open var onResize: ((CGRect) -> Void)?
}

class KSV_PlatformDocumentView: KSV_PlatformView {
  override func layoutSubviews() {
    super.layoutSubviews()
    updateResize()
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    updateResize()
  }

  private var lastFrame: CGRect?
  func updateResize() {
    guard frame != lastFrame else { return }
    lastFrame = frame
    onResize?(frame)
  }

  open var onResize: ((CGRect) -> Void)?
}

class KSV_WrappedContentPlatformView: KSV_PlatformView { }

extension UIView{
  func ksv_HitTestExternal(_ point: CGPoint, _ event: UIEvent? = nil) -> UIView? {
    hitTest(point, with: event)
  }
}

#endif // #if os(iOS)
