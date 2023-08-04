//
//  File.swift
//
//
//  Created by cms on 2/10/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions

/*
 ksvProxy - passed in closure to wrapped content when KSV is called, just like ScrollViewProxy.
            ksVProxy has scrollViewProxy + two more functions
 withStableScroll(_:{}) - available to wrapped content to enforce stable scrolling when programmatic changes are made to content size of enclosing frame size. KSV automatically handles scrolling and resizing events. But this allows handling programmatic events.
 scrollToCenterAnchor() - mainly for testing purposes. But available if KSV
 */
public struct KangarooScrollViewProxy {

	public var scrollViewProxy: ScrollViewProxy?
	public weak var ksvScrollManager: KSVScrollManager?


	var scrollToCenterAnchorAction: () -> Void
	var startStableScrollAction: () -> Void
	// 'scrollToCenterAnchor' &  'startStableScroll' constructed within KangarooScrollView to capture 'proxyRequestedStableScroll'.
	// ksvProxy can be used to initiate.

	// KSVProxy receives
	public func withStableScroll(updateHandler: () -> Void){
		LLog()
		// withAnimation(.default){
		startStableScrollAction()
		updateHandler()
	}
	

	// KSVProxy receives
	public func scrollToCenterAnchor(){
		LLog()
		self.scrollToCenterAnchorAction()
	}

	public var selectedStoplight: Binding<Stoplight?>


	public func snapToSelectedStop(){
		self.ksvScrollManager?.snapToSelectedStop()
	}
	public func snapToNearestStop(){
		self.ksvScrollManager?.snapToNearestStop()
	}

	// -- modern:


}

