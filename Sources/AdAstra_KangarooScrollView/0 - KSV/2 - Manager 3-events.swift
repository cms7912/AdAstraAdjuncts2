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

// Initial setup
extension KSVScrollManager {
	func initialSetup(){
		// return
		if initialSetupDone { return }
		guard paneSetupDone && contentSetupDone else { return }
		llog("🔰 doing initial setup 🔰")
		rawContentRectWhenLastStationary = rawContentRect
		selectedStoplightSetup()
		snapToSelectedStop()
		initialSetupDone = true
	}


}

// Pane Events
extension KSVScrollManager {

	// * Pane Frame Resizing *
	 func resizingPane(to newLength: CGFloat){
		llog("to \(newLength)")
		guard initialSetupDone else { return }
		// don't start frameResizing if pane & content views haven't yet completed loading their sizes
		resizingPaneInProgress = true
		//maintainPosition()
     
     
	}

	func resizingPaneStopped(at newSize: CGSize?){
		llog("at: \(newSize.dd)")

		resizingPaneInProgress = false
    // selectedStoplight?.map.notchPositionsChanged()
    endSnapScroll()
    didBecomeStationary() // also updates contentRect because during stableScroll the pane resizing can change the content offset
	}
}


// Content Events
extension KSVScrollManager {


	// * Scrolling *
  func scrollingContent(to rawContentRect: CGRect, locked: Bool = false){
		// llog("")
		guard initialSetupDone else { return }
		// don't start frameResizing if pane & content views haven't yet completed loading their sizes

		// scrollVelocityDetector.send(newContentRect.origin.forDimension(direction))

		if resizingPaneInProgress {
			llog("resizingPaneInProgress, returning early")
			return
		}
		// llog("to: \(newContentRect)")
		// if locked || scrollingInProgressLocked {
		// 	llog(if: scrollingInProgressLocked.isFalse, "scrollingInProgressLocked turning on")
		// 	scrollingInProgressLocked =  true
		// 	return
		// 	// currently not supporting stableScroll when using 'scrollingInProgressLocked' ... could, but no need to since 'locked' is only used by AppKit when knowing scrolling start/end
		// }

		var stableScrollInProgress: Bool = clientRequestedStableScroll
    if stableScrollInProgress.isFalse, stablizeResizings.isTrue,
			 rawContentRect.size.forDimension(direction) != rawContentRectWhenLastStationary.size?.forDimension(direction) {
			// if content's CGRect changed...
			// the content size changed--assume content updated and KSV needs to update with stableScroll
      
			stableScrollInProgress = true
			llog("currentSize: \(rawContentRect.size.forDimension(direction)) != StationarySize: \(rawContentRectWhenLastStationary.size?.forDimension(direction) ?? -1)")
      
      // TEMP turning off stableScroll to diagnose resizing problem.  StableScroll not needed in Caleo, so might ship without it active.
       stableScrollInProgress = false
		}

		if stableScrollInProgress {
			llog ("⚖️ stableScrollInProgress ⚖️")
			// under stable scroll, actively move to keep on position
			maintainPosition()
		} else {
			// under normal scrolling updates
			// - the selectedStop's notch & divot don't change position, so no need to update them

			if snapScrollingInProgress.isFalse {
				updateScrolling(interactive: true, snap: false, stationed: false)
			}

		}
	}

	func scrollEnded(at rawContentRect: CGRect?){
		llog("🏁 at: \(rawContentRect.dd) 🏁")
		// not calling updateScrolling() here, let endSnapScroll() and snapToNearestStop() set those.

		guard let rawContentRect = rawContentRect else {
			// first published is nil, but initialSetup() does snapToNearestStop(), so need to stop snapScroll
			endSnapScroll()
			didBecomeStationary()
			return
		}
		self.rawContentRect = rawContentRect
		// if unlock {
		//   // scrollingInProgressLocked = false
		//   snapToNearestStop()
		//   return
		// }
		if snapScrollingInProgress {
			endSnapScroll()
		}
	// } else if snapToStopsEnabled {
	// 		llog("🏹 user scrolling stopped, will select nearest stoplight 🏹")
	// 		//updateScrolling(interactive: false, snap: true, stationed: false)
	// 		snapToNearestStop()
	// 		if snapScrollingInProgress {
	// 			// initiated a snap, skip 'didBecomeStationary()'
	// 			return
	// 		}
	// 	}
		snapToNearestStop()
		if snapScrollingInProgress {
			// initiated a snap, skip 'didBecomeStationary()'
			return
		}

		didBecomeStationary()

	}
  
	func didBecomeStationary(){
		updateScrolling(interactive: false, snap: false, stationed: true)
		rawContentRectWhenLastStationary = rawContentRect
		paneCenterInContentWhenLastStationary = paneCenterInContent
		contentAtFrontEdgeWhenLastStationary = (rawContentOffset == 0)
		contentAtBackEdgeWhenLastStationary = (
			rawContentOffset == (paneLength - contentLength)) // subtracting smaller length from bigger length because rawContentOffset grows as negative
	}

}

