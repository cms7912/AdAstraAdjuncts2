//
//  File.swift
//  
//
//  Created by cms on 3/12/22.
//

import Foundation

#if os(macOS)
import AppKit

extension KSV_PlatformScrollViewController {
	func addNotificationObservers(){

		if false {
		// Handle scrolling start & end
		NotificationCenter.default.addObserver(
			forName: NSScrollView.willStartLiveScrollNotification,
			object: theScrollView,
			queue: .main ) { [weak self] (n) in
				guard let self = self else { return }
				// self.llog("start:\(self.rawDocumentFrame)")
				// self.ksvScrollManager.scrollingContent( to: self.scrollView.rawContentFrame, locked: true)
			}
			}

		if true {
		NotificationCenter.default.addObserver(
			forName: NSScrollView.didLiveScrollNotification,
			object: theScrollView,
			queue: .main ) { [weak self] (n) in
				guard let self = self else { return }
        self.updateTrackingContentFrame()
			}
			}

		NotificationCenter.default.addObserver(
			forName: NSScrollView.didEndLiveScrollNotification,
			object: theScrollView,
			queue: .main ) { [weak self] (n) in
				guard let self = self else { return }
				self.llog("end:\(self.rawDocumentFrame)")
        self.updateTrackingContentFrame(scrollEnded: true)
}



		// Update Pane Frame
		if false {
		self.view.postsBoundsChangedNotifications = true
		NotificationCenter.default.addObserver(
		  forName: NSView.boundsDidChangeNotification,
		  object: view,
		  queue: .main ) { [weak self] (n) in
		    guard let self = self else { return }
		    // self.ksvScrollManager.updateTrackingPaneSize(with: self.scrollView.bounds.size)
			}
		}
		// 'boundsDidChangeNotification' doesn't catch these changes but 'frameDidChangeNotification' does

		// ksvScrollManager.updateTrackingPaneSize(with: view.frame.size)
    updateTrackingPaneSize() 
		self.view.postsFrameChangedNotifications = true
		NotificationCenter.default.addObserver(
			forName: NSView.frameDidChangeNotification,
			object: view,
			queue: .main ) { [weak self] (n) in
				guard let self = self else { return }
				if self.lastPaneSize != self.view.bounds.size {
					self.lastPaneSize = self.view.bounds.size
          self.updateTrackingPaneSize()

				}
			}



		// Update Content Frame Size
		self.updateTrackingContentFrame()
		self.theScrollView.contentView.postsBoundsChangedNotifications = true
		NotificationCenter.default.addObserver(
			forName: NSView.boundsDidChangeNotification,
			object: theScrollView.contentView,
			queue: .main ) { [weak self] (n) in
				guard let self = self else { return }
        self.updateTrackingContentFrame() }
	}
}

#endif
