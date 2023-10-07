//
//  File.swift
//  
//
//  Created by cms on 3/22/22.
//

import Foundation
import AdAstraExtensions
import AdAstraBridgingByShim
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Combine

extension KSV_UniversalSuffixScrollViewController {
  
  func extendedViewDidLoad() {
    // before this, platform-specific viewDidLoad() should set up:
    // - super.viewDidLoad()
    // - adding documentView to scrollView
    
    addChild(hostingViewController)
    

		setupDocumentViewContentsConstraints()

    setupExtendedScrollProportionalSizeConstraints()
    
    setupExtendedScrollSizeSubscriptions()
  }
  
  func extendedUniversalViewDidAppear() {
		// self.view.superview!.isOpaque = false
		// self.view.superview!.layer.opacity = 0

    ksvScrollManager.updateTrackingPaneSize(with: theScrollView.frame.size)
    ksvScrollManager.resizingPaneStopped(at: theScrollView.frame.size)
    ksvScrollManager.updateTrackingContentFrame(with: rawDocumentFrame)
    ksvScrollManager.scrollEnded(at: rawDocumentFrame)
  }
  
}

extension KSV_UniversalSuffixScrollViewController {

	func setupDocumentViewContentsConstraints() {
		var allConstraints: [NSLayoutConstraint] = .empty

		let stackOfViews = [ underScrollView,
												 wrappedContentView,
												 overScrollView]

		for eachView in stackOfViews {
			documentView.addSubview(eachView)

			for sideDirection in [directionCounterOrientationFront, directionCounterOrientationBack] {
				let sideConstraint = NSLayoutConstraint(
					item: documentView, attribute: sideDirection,
					relatedBy: .equal,
					toItem: eachView, attribute: sideDirection,
					multiplier: 1, constant: 0)
				allConstraints.append(sideConstraint)
			}
		}


		let frontBumperConstraint = NSLayoutConstraint(
			item: documentView, attribute: directionOrientationFront,
			relatedBy: .equal,
			toItem: underScrollView, attribute: directionOrientationFront,
			multiplier: 1, constant: 0)
		allConstraints.append(frontBumperConstraint)

		let underScrollToWrappedContentConstraint = NSLayoutConstraint(
			item: underScrollView, attribute: directionOrientationBack,
			relatedBy: .equal,
			toItem: wrappedContentView, attribute: directionOrientationFront,
			multiplier: 1, constant: 0)
		allConstraints.append(underScrollToWrappedContentConstraint)

		let WrappedContentToOverScrollConstraint = NSLayoutConstraint(
			item: wrappedContentView, attribute: directionOrientationBack,
			relatedBy: .equal,
			toItem: overScrollView, attribute: directionOrientationFront,
			multiplier: 1, constant: 0)
		allConstraints.append(WrappedContentToOverScrollConstraint)

		let backBumperConstraint = NSLayoutConstraint(
			item: overScrollView, attribute: directionOrientationBack,
			relatedBy: .equal,
			toItem: documentView, attribute: directionOrientationBack,
			multiplier: 1, constant: 0)
		allConstraints.append(backBumperConstraint)



		allConstraints.forEach{
			documentView.addConstraint($0)
			$0.isActive = true
		}

	}

  func setupExtendedScrollProportionalSizeConstraints(){
    
    // Set up ExtendedScrolls as percentage of wrappedContentView
    self.underScrollLengthLayoutConstraint =
    NSLayoutConstraint(
      item: underScrollView,
      attribute: directionConstraintAttribute,
      relatedBy: .equal,
      toItem: wrappedContentView,
      attribute: directionConstraintAttribute,
      multiplier: gvm.underScrollOverScrollPercentage.0 ?? 0,
      constant: 0)

		self.overScrollLengthLayoutConstraint =
    NSLayoutConstraint(
      item: overScrollView,
      attribute: directionConstraintAttribute,
      relatedBy: .equal,
      toItem: wrappedContentView,
      attribute: directionConstraintAttribute,
      multiplier: gvm.underScrollOverScrollPercentage.1 ?? 0,
      constant: 0)

		// add the above constraints:
    [ underScrollLengthLayoutConstraint,
      overScrollLengthLayoutConstraint
    ].forEach{ newConstraint in
      guard let newConstraint = newConstraint else { return }
      theScrollView.addConstraint(newConstraint)
      newConstraint.isActive = true
    }
  }
  
  func setupExtendedScrollSizeSubscriptions() {
    if let underScrollPublisher = gvm.underScrollOverScrollPublishedSizes.underScroll {
      underScrollPublisher
        .sink{ [weak self] newValue in
          guard let newValue = newValue else {return}
          self?.updateUnderScrollSize(newValue)
        }
        .store(in: &underScrollObserverStorage)
    }
    
    if let overScrollPublisher = gvm.underScrollOverScrollPublishedSizes.overScroll {
      overScrollPublisher
        .sink{ [weak self] newValue in
          guard let newValue = newValue else {return}
          self?.updateOverScrollSize(newValue)
        }
        .store(in: &overScrollObserverStorage)
    }
  }
  
  
  func updateUnderScrollSize(_ newValue: CGSize){
    underScrollLengthLayoutConstraint?.constant = newValue.for(gvm.direction)
  }
  func updateOverScrollSize(_ newValue: CGSize){
    overScrollLengthLayoutConstraint?.constant = newValue.for(gvm.direction)
  }
  
  
}
