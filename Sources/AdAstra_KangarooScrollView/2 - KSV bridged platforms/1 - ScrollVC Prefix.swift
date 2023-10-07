//
//  File.swift
//  
//
//  Created by cms on 4/21/22.
//

import Foundation

import Foundation
import SwiftUI
import AdAstraExtensions

import AdAstraBridgingByShim
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AALogger
/*
 
 - KSV_ScrollViewController
 - HostingViewController
 
 
 stageView = VC.view
 - scrollView
 - documentView
 1 underScrollView (ExtendedScrollView)
 2 wrappedContentView
 - hostingViewController.view
 3 overScrollView (ExtendedScrollView)
 
 */


class KSV_UniversalPrefixScrollViewController<Content: View>: UINSViewController, ObservableObjectWithLLogging {
  @ObservedObject var gvm: KangarooScrollViewGenericViewModel
  @Binding var ksvProxy: KangarooScrollViewProxy
  var wrappedView: (KangarooScrollViewProxy) -> Content
  
  //var scrollView: KSV_ScrollView
  
  init(
    ksvScrollManager: KSVScrollManager,
    gvm: KangarooScrollViewGenericViewModel,
    ksvProxy: Binding<KangarooScrollViewProxy>,
    wrappedView: @escaping (KangarooScrollViewProxy) -> Content
    
  ){
    self.ksvScrollManager = ksvScrollManager
    self.gvm = gvm
    self._ksvProxy = ksvProxy
    self.wrappedView = wrappedView
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @ObservedObject var ksvScrollManager: KSVScrollManager
  var rawDocumentFrame: CGRect {
    // let newValue = wrappedContentView.convert(self.wrappedContentView.bounds, to: theScrollView) // - works on macOS
    let newValue = wrappedContentView.convert(self.wrappedContentView.bounds, to: stageView)
    // llog("\(newValue)")
    return newValue
    // this convert makes offset negative
  }
  
  
  lazy var directionConstraintAttribute =  ksvScrollManager.direction.isHorizontal ?
  NSLayoutConstraint.Attribute.width : NSLayoutConstraint.Attribute.height
  lazy var directionCounterConstraintAttribute =  ksvScrollManager.direction.isHorizontal ?
  NSLayoutConstraint.Attribute.height : NSLayoutConstraint.Attribute.width
  
  lazy var directionStackOrientation = ksvScrollManager.direction.isHorizontal ? UINSUserInterfaceLayoutOrientation.horizontal : UINSUserInterfaceLayoutOrientation.vertical
  
  lazy var directionOrientationFront = ksvScrollManager.direction.isHorizontal ? NSLayoutConstraint.Attribute.leading : NSLayoutConstraint.Attribute.top
  lazy var directionOrientationBack = ksvScrollManager.direction.isHorizontal ? NSLayoutConstraint.Attribute.trailing : NSLayoutConstraint.Attribute.bottom
  
  lazy var directionCounterOrientationFront = ksvScrollManager.direction.isHorizontal ?
  NSLayoutConstraint.Attribute.top : NSLayoutConstraint.Attribute.leading
  
  lazy var directionCounterOrientationBack = ksvScrollManager.direction.isHorizontal ?
  NSLayoutConstraint.Attribute.bottom : NSLayoutConstraint.Attribute.trailing
  
  
  
  lazy var hostingViewController: KSV_HostingController<Content> = {
    let newHostController = KSV_HostingController(rootView: wrappedView(ksvProxy) )
    return newHostController
  }()
  
  
  
  lazy var stageView: KSV_StageView = {
    var newStageView = KSV_StageView()
    // newStageView.translatesAutoresizingMaskIntoConstraints = false // to be the viewController.view this needs to be left true 
    newStageView.ksvScrollManager = ksvScrollManager
    newStageView.wrappedContentView = wrappedContentView
    return newStageView
  }()
  
  
  lazy var theScrollView: KSV_ScrollView = {
    var newScrollView = KSV_ScrollView()
    newScrollView.translatesAutoresizingMaskIntoConstraints = false
    newScrollView.ksvScrollManager = ksvScrollManager
    platformSetupScrollView(&newScrollView)
    return newScrollView
  }()
  
  lazy var documentView: KSV_DocumentView = {
    var documentView = KSV_DocumentView()
    documentView.translatesAutoresizingMaskIntoConstraints = false
    documentView.ksvScrollManager = ksvScrollManager
    return documentView
  }()
  
  lazy var wrappedContentView: KSV_WrappedContentView = {
    let wrappedContentView = KSV_WrappedContentView()
    wrappedContentView.translatesAutoresizingMaskIntoConstraints = false
    wrappedContentView.ksvScrollManager = ksvScrollManager
    wrappedContentView.backgroundColor = .clear
    wrappedContentView.addSubviewWithAnchorConstraints(hostingViewController.view)
    return wrappedContentView
  }()
  
  lazy var underScrollView: KSV_UnderExtendedScrollView = {
    let underScrollView = KSV_UnderExtendedScrollView()
    underScrollView.translatesAutoresizingMaskIntoConstraints = false
    underScrollView.ksvScrollManager = ksvScrollManager
    return underScrollView }()
  var underScrollLengthLayoutConstraint: NSLayoutConstraint?
  var underScrollObserverStorage = Set<AnyCancellable>()
  lazy var underScrollViewBackgroundColor = gvm.underScrollOverScrollColor.0
  // UINSColor.systemBlue.withAlphaComponent(0.20)
  
  
  lazy var overScrollView: KSV_OverExtendedScrollView = {
    let overScrollView = KSV_OverExtendedScrollView()
    overScrollView.translatesAutoresizingMaskIntoConstraints = false
    overScrollView.ksvScrollManager = ksvScrollManager
    return overScrollView }()
  var overScrollLengthLayoutConstraint: NSLayoutConstraint?
  var overScrollObserverStorage = Set<AnyCancellable>()
  lazy var overScrollViewBackgroundColor = gvm.underScrollOverScrollColor.1
  // UINSColor.systemRed.withAlphaComponent(1.0)
  
	func universalViewDidAppear() { }
	func platformSetupScrollView(_ newScrollView: inout KSV_ScrollView){}






	// These actions are grouped here together to provide common routing point going from platform-specific callers to KSV tracking

  func updateTrackingPaneSize(){
    self.ksvScrollManager.updateTrackingPaneSize(with: view.frame.size)
    self.stageView.ksvDrawAllPositions()
  }
  
  func updateTrackingContentFrame(scrollEnded: Bool = false){
    self.ksvScrollManager.updateTrackingContentFrame(with: self.rawDocumentFrame)
    if scrollEnded {
      self.ksvScrollManager.scrollEnded(at: self.rawDocumentFrame)
    }
    self.wrappedContentView.ksvDrawAllPositions()
  }

  func scrollViewDidEndDraggingWithoutDeceleration(){
    updateTrackingContentFrame()
    self.ksvScrollManager.scrollEnded(at: self.rawDocumentFrame)
    self.wrappedContentView.ksvDrawAllPositions()
    self.stageView.ksvDrawAllPositions()
  }
  
  func scrollViewDidEndDecelerating(){
    updateTrackingContentFrame()
    self.ksvScrollManager.snapToNearestStop()
  }
  
}
