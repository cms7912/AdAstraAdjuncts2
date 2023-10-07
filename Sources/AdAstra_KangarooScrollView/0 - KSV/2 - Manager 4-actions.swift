//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
import AdAstraExtensions
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



extension KSVScrollManager {

	// calculate to find, then snap to nearest stop.
	func snapToNearestStop(){
		selectNearestStoplight()
		snapToSelectedStop()
	}

  /// maintains scrollView to hover over same content center point, or leading/trailing if at an end during pane's reszing  or contents resizing
  func maintainPosition(){
    guard stablizeResizings.isTrue || clientRequestedStableScroll else { return }
    clientRequestedStableScroll = false // if on, then turn off

    if selectedStoplight.isNotNil {
      snapToSelectedStop()
      return
    }
    
    llog("pre-maintain status:")
    llog("deltaShift: \(deltaShift)")
    llog("paneCenterInContentWhenLastStationary: \(paneCenterInContentWhenLastStationary)")
    llog("contentAtBackEdgeWhenLastStationary: \(contentAtFrontEdgeWhenLastStationary)")
    llog("contentAtBackEdgeWhenLastStationary: \(contentAtFrontEdgeWhenLastStationary)")
    
    // guard let paneCenterInContent = paneCenterInContent,
    // let deltaShift = deltaShift else { return }
		var positionShift: CGFloat = 0
    if contentAtFrontEdgeWhenLastStationary {
      positionShift = rawContentOffset ?? 0

    } else if contentAtBackEdgeWhenLastStationary {
      if let paneLength = paneLength,
         let contentLength = contentLength{
      positionShift = paneLength - contentLength
      }
    } else {
      if let paneCenterInContentAsRatioWhenLastStationary = paneCenterInContentAsRatioWhenLastStationary,
      let paneCenterInContent = paneCenterInContent {
      positionShift = paneCenterInContentAsRatioWhenLastStationary - paneCenterInContent
      }
    }
    
    guard positionShift.isZero.isFalse else {
      llog("no maintaining shift needed"); return }

    updateScrolling(interactive: false, snap: true, stationed: false)
    scrollVCDelegate?.move(by: positionShift)

  }


	func selectNearestStoplight(){
		// llog("🦘 🔍")
    guard kangarooMapArray.isNotEmpty else { return }

    // Step 1: Find notch-divot pair that best fit together
    var bestStoplight: Stoplight?
		for map in kangarooMapArray  {
			bestStoplight = map.bestStoplight()
			if bestStoplight.isNotNil { break } // maps in priority order, exit when first Stoplight found
		}

		// 🚦
		selectedStoplight = bestStoplight // including nil if none to select
	}

	public func snapToSelectedStop(){
		llog("🦘 🎯")
		guard let rawContentRect = rawContentRect else { llog ("missing rawContentRect")
      return }

		clientRequestedStableScroll = false // if on, then turn off

		// Step 2:
		// calculate notch's offset from outer frame's center
		// place AnchorRect at the offset
    llog("pre-snap deltaShift: \(deltaShift.dd)")
		guard let paneCenterInContent = paneCenterInContent,
					let deltaShift = deltaShift,
    let scrollVCDelegate = scrollVCDelegate else {
      llog ("missing paneCenterInContent/deltaShift/scrollVCDelegate")
      return }

		guard deltaShift.isZero.isFalse && snapToStopsEnabled else {
			llog("no snapping needed"); return }


		// 🎯 commit move center anchor
		// Step 3:
		// scroll to AnchorRect, resulting in actual notch alignment with divot
		updateScrolling(interactive: false, snap: true, stationed: false)
    scrollVCDelegate.move(by: deltaShift)

	}
  
  
  
	func endSnapScroll(){
		llog("post-snap deltaShift: \(deltaShift)")

		if deltaShift.ifNil0.isZero.isFalse { // if delta offset still exists, try again
llog("!! deltaShift offset is still off !!")
return
			
      #if Disabled
			if snapScrollingRetryInProgress.isFalse { // check that this is not a re-try
				llog("deltaShift still exists, will try snapping again: \(deltaShift.dd)")
				// return;
				// snapScrollingRetryInProgress = true
				// snapToSelectedStop()
        // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(KangarooScrollView_viaSwiftUI_ViewModel.ScrollingCompletedSeconds * 2))){[weak self] in
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(0.2) * 2)) {[weak self] in
					guard let self = self else { return }
					if self.deltaShift.ifNil0.isZero.isFalse {
						self.llog("deltaShift STILL exists, will try snapping again again: \(self.deltaShift.dd)")
						self.snapScrollingRetryInProgress = true
						self.snapToSelectedStop()
					} else {
						self.llog("no deltaShift fix needed, finally!")
					}
				}
				// return
        
			} else {
				llog("deltaShift still exists, but already tried re-snapping: \(deltaShift.dd)")
			}
      #endif
      
			// even this double checking doesn't work -- when scrollView gets stuck, it stays stuck
			// } else {
		} else {
			// llog("no deltaShift fix needed!")
		}
		// snapScrollingInProgress = false
		snapScrollingRetryInProgress = false
	}

  
  func reviseDragEndingAt(targetOffset: UnsafeMutablePointer<CGPoint>,
													currentOffset: CGPoint,
													currentRawDocumentFrame: CGRect){
		llog("initial targetContentOffset: \(targetOffset.pointee)")

		// guard // let deltaShift = rawContentOffset,
		// let deltaShift = deltaShift else { return }

		let originalTargetOffset = targetOffset.pointee * 1  //targetContentOffset seems to not be a raw value but an absolute value

		// updateScrolling(interactive: false, snap: true, stationed: false)
		// updateTrackingContentFrame(with: originalTargetOffset)
		guard let rawContentRectOriginal = rawContentRect else { assert(false); return }
		// let rawContentRectUpdated = CGRect(origin: originalTargetOffset, size: rawContentRectOriginal.size)

		let deltaToTargetOffset = currentOffset - originalTargetOffset

		let targetRawDocumentFrame = CGRect(
			origin: currentRawDocumentFrame.origin + deltaToTargetOffset,
			size: currentRawDocumentFrame.size)

		updateTrackingContentFrame(with: targetRawDocumentFrame)

		selectNearestStoplight()

		llog("deltaShift: \(deltaShift.dd)")

		let updatedTargetOffset = originalTargetOffset + CGPoint(direction, deltaShift.asZeroIfNil)
		targetOffset.pointee = updatedTargetOffset * 1
		llog("revised targetContentOffset: \(targetOffset.pointee)")
		// scrollVCDelegate?.theScrollView.setContentOffset(newPoint, animated: true)

		// scrollEnded(at: self.rawDocumentFrame)

		// snapToSelectedStop()
		updateScrolling(interactive: false, snap: true, stationed: false)
	}

}
