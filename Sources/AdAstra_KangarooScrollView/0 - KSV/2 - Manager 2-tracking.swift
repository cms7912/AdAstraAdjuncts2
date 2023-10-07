//
//  File.swift
//  
//
//  Created by cms on 3/11/22.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Pane Tracking
extension KSVScrollManager {
	func updateTrackingPaneSize(with newPaneSize: CGSize){
		let newPaneLength = newPaneSize.for(direction)
		if self.paneLength == newPaneLength { return }

		self.paneLength = newPaneLength
		resizingPane(to: newPaneLength)
		paneResizedDetector?.send(newPaneSize)
		if paneSetupDone.isFalse && newPaneSize != .zero {
			paneSetupDone = true
			initialSetup()
		}
	}

}

// Content Tracking
extension KSVScrollManager {
	func updateTrackingContentFrame(with rawContentRect: CGRect){
		// llog("to: \(rawContentRect)")
		// var contentSizeChanged: Bool = false
		// if contentSize != rawContentRect.size { contentSizeChanged = true }
		contentLength = rawContentRect.size.for(direction) // send this update first so .rawContentRect can trigger object.willSend()
		self.rawContentRect = rawContentRect
		if contentSetupDone.isFalse && rawContentRect != .zero {
			contentSetupDone = true
			initialSetup()
			guard initialSetupDone else { return }
		}
		// if contentSizeChanged {
		// selectedStoplight?.map.divotPositionsChanged()
		// }
		self.scrollingContent(to: rawContentRect)
	}
  func updateTrackingContentFrame(with rawContentPoint: CGPoint){
    // llog("to: \(rawContentPoint)")

    guard let rawContentRectOriginal = rawContentRect else { assert(false); return }
    let rawContentRectUpdated = CGRect(origin: rawContentPoint, size: rawContentRectOriginal.size)
		updateTrackingContentFrame(with: rawContentRectUpdated)
  }

}
