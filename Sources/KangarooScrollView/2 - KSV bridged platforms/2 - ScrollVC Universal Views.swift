//
//  File.swift
//  
//
//  Created by cms on 4/21/22.
//

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



class KSV_StageView: KSV_PlatformStageView {
  // weak var ksvScrollManager: KSVScrollManager?
  // weak var wrappedContentView: KSV_WrappedContentView?
  
  override func ksv_HitTest(_ point: CGPoint, _ event: UINSEvent? ) -> UINSView? {
    func llog(_ s: String) {
      // self.llog(s)
    }
    guard let destinationDelegateView = ksvScrollManager?.gesturesBackgroundDestinationDelegate else {
			llog("no destinationDelegateView, will return super.ksv_HitTest()")
      return super.ksv_HitTest(point, event)
    }
    
    let test = super.ksv_HitTest(point, event)
    if let test = test,
       let wrappedContentView = wrappedContentView,
       (test.isDescendant(of: wrappedContentView)
        || test.isDescendant(of: destinationDelegateView ))
		{ // test == dv when subview (e.g. ExtendedScrollView) has already evaluated hit and returned the dv destination
			test.isDescendant(of: wrappedContentView) ? llog("tapped wrappedContentView") : nil
			test.isDescendant(of: destinationDelegateView) ? llog("tapped destinationDelegateView") : nil
			llog("will return super.ksv_HitTest()")
      return test
    }
		llog("will return destinationDelegateView.ksv_HitTestExternal()")
    return destinationDelegateView.ksv_HitTestExternal( self.convert(point, to: destinationDelegateView), event)
  }

	func ksv_HitTest2(_ point: CGPoint, _ event: UINSEvent? ) -> UINSView? {
		guard let destinationDelegateView = ksvScrollManager?.gesturesBackgroundDestinationDelegate else {
			llog("no destinationDelegateView, will return super.ksv_HitTest()")
			return super.ksv_HitTest(point, event)
		}

		let test = super.ksv_HitTest(point, event)
		if let test = test,
			 let wrappedContentView = wrappedContentView,
			 test.isDescendant(of: wrappedContentView)
		{
			llog("tapped wrappedContentView")
			llog("will return super.ksv_HitTest()")
			return test
		}
		llog("will return nil")
		return nil
	}

	func ksv_HitTest3(_ point: CGPoint, _ event: UINSEvent? ) -> UINSView? {
		// guard let destinationDelegateView = ksvScrollManager?.gesturesBackgroundDestinationDelegate else {
		// 	llog("no destinationDelegateView, will return super.ksv_HitTest()")
		// 	return super.ksv_HitTest(point, event)
		// }
  //
		// let test = super.ksv_HitTest(point, event)
		// if let test = test,
		// 	 let wrappedContentView = wrappedContentView,
		// 	 test.isDescendant(of: wrappedContentView)
		// {
		// 	llog("tapped wrappedContentView")
		// 	llog("will return super.ksv_HitTest()")
		// 	return test
		// }
		// llog("will return nil")
		// return nil
		super.ksv_HitTest(point, event)
	}


  override func ksvDrawAllPositions() {
		guard llogIsEnabled else { return }
    super.ksvDrawAllPositions()
    if let map = ksvScrollManager?.currentMap as? MapWithPositions {
      map.notchPositions.forEach{
        ksvDrawPosition($0, .systemBlue.withAlphaComponent(0.7), 3.0)
      }
    }
  }
}

public class KSV_ScrollView: KSV_PlatformScrollView {
	override var myParentScrollView: KSV_ScrollView? {
		let myScrollingStatusDelegate =  ksvScrollManager?.scrollingStatusDelegate
		let myParentScrollManager = myScrollingStatusDelegate?.parentKSVScrollManager
		let myParentScrollVC = myParentScrollManager?.scrollVCDelegate
		let myParentScrollView = myParentScrollVC?.theScrollView
		return myParentScrollView
	}

	override var myGrandparentScrollView: KSV_ScrollView? {
		let myScrollingStatusDelegate =  ksvScrollManager?.scrollingStatusDelegate
		let myParentScrollManager = myScrollingStatusDelegate?.parentKSVScrollManager

		let myParentScrollingStatusDelegate = myParentScrollManager?.scrollingStatusDelegate
		let myGrandparentScrollManager = myParentScrollingStatusDelegate?.parentKSVScrollManager

		let myGrandparentScrollVC = myGrandparentScrollManager?.scrollVCDelegate
		let myGrandparentScrollView = myGrandparentScrollVC?.theScrollView
		return myGrandparentScrollView
	}

}


class KSV_StackView: KSV_PlatformStackView { }
class KSV_DocumentView: KSV_PlatformDocumentView { }

class KSV_WrappedContentView: KSV_WrappedContentPlatformView {
	override func ksvDrawAllPositions() {
		guard llogIsEnabled else { return }
		super.ksvDrawAllPositions()
		ksvDrawPosition(ksvScrollManager?.notchPositionInContentFrame, .systemPurple.withAlphaComponent(0.5), 8.0)
		if let map = ksvScrollManager?.currentMap as? MapWithPositions {
			map.divotPositions.forEach{
				ksvDrawPosition($0, .systemRed, 2.0)
			}
		}
	}
}

class KSV_HostingController<Content>: KSV_PlatformHostingController<Content> where Content: View {
  // override func viewDidLayout() {
  // }
  //  override func viewDidLayoutSubviews() {
  //    super.viewDidLayoutSubviews()
  //    self.view.invalidateIntrinsicContentSize()
  //    //https://stackoverflow.com/questions/58399123/uihostingcontroller-should-expand-to-fit-contents
  //  }
}

class KSV_ExtendedScrollView: KSV_PlatformView {
#if os(macOS)
  // public var isUserInteractionEnabled: Bool = true
	#elseif os(iOS)

#endif
  // weak var ksvScrollManager: KSVScrollManager?
  // weak var wrappedContentView: KSV_WrappedContentView?
  
   func ksv_HitTestWORKING(_ point: CGPoint, _ event: UINSEvent? ) -> UINSView? {
    // if self.bounds.width != 0 && self.bounds.height != 0 { return nil } // even when .zero size the view still picks up hitTests
    let test = super.ksv_HitTest(point, event)
    if test.isNil { return nil }
    // if test not nil, then is within this ExtendedScrollView and needs to be sent to backgroundDestinationDelegate
    if let dv = ksvScrollManager?.gesturesBackgroundDestinationDelegate {
      return dv.ksv_HitTestExternal( self.convert(point, to: dv), event)
    }
    // failed to get destination delegate's view, will handle locally
    return test
  }
}
class KSV_UnderExtendedScrollView: KSV_ExtendedScrollView { }
class KSV_OverExtendedScrollView: KSV_ExtendedScrollView { }

extension UINSColor {
  func patternStripes(_ color2: UINSColor = .white, barThickness t: CGFloat = 25.0) -> UINSColor {
#if RELEASE
    return UINSColor.clear
#endif
#if os(iOS)
    let dim: CGFloat = t * 2.0 * sqrt(2.0)
    
    let img = UIGraphicsImageRenderer(size: .init(width: dim, height: dim)).image { context in
      
      // rotate the context and shift up
      context.cgContext.rotate(by: CGFloat.pi / 4.0)
      context.cgContext.translateBy(x: 0.0, y: -2.0 * t)
      
      let bars: [(UINSColor,UIBezierPath)] = [
        (self,  UIBezierPath(rect: .init(x: 0.0, y: 0.0, width: dim * 2.0, height: t))),
        (color2,UIBezierPath(rect: .init(x: 0.0, y: t, width: dim * 2.0, height: t)))
      ]
      
      bars.forEach {  $0.0.setFill(); $0.1.fill() }
      
      // move down and paint again
      context.cgContext.translateBy(x: 0.0, y: 2.0 * t)
      bars.forEach {  $0.0.setFill(); $0.1.fill() }
    }
    
    return UINSColor(patternImage: img)
#elseif os(macOS)
    return self.withAlphaComponent(0.20)
#endif
    // https://stackoverflow.com/a/68500130/6911652
  }
  
}
