//
//  File.swift
//  
//
//  Created by cms on 3/6/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions

/*
 - KSV - body_UIKit
 - KSV_UIViewControllerRepresentable (SwiftUI -> UIKit)
 - KSV_ScrollViewController (UIKIT ViewController)
 - KSV_UIScrollView
 -
 -
 */

#if os(macOS) && DEBUGXX

struct KangarooScrollView_viaAppKit<Content: View>: View {
  @EnvironmentObject var ksvC: KSVScrollManager
  @EnvironmentObject var gvm: KangarooScrollViewGenericViewModel
  
  var wrappedContent: (KangarooScrollViewProxy) -> Content
  var body: some View {
    KSV_ViewControllerRepresentable<Content>(
      ksvProxy:
        KangarooScrollViewProxy(
          scrollToCenterAnchorAction: { },
          startStableScrollAction: {  ksvC.clientRequestedStableScroll = true },
          selectedStoplight: $ksvC.selectedStoplight),
      ksvScrollManager: self.ksvC,
      gvm: self.gvm,
      wrappedView: wrappedContent
    )
    // Color.systemRed
  }
}

struct KSV_ViewControllerRepresentable<Content: View>: NSViewControllerRepresentable {
  
  @State var ksvProxy: KangarooScrollViewProxy
  @ObservedObject var ksvScrollManager: KSVScrollManager
  @ObservedObject var gvm: KangarooScrollViewGenericViewModel
  var wrappedView: (KangarooScrollViewProxy) -> Content
  
  func makeNSViewController(context: Context) -> KSV_ScrollViewController<Content> {
    let viewController = KSV_ScrollViewController<Content>(
			ksvScrollManager: ksvScrollManager,
      gvm: gvm,
      ksvProxy: $ksvProxy,
      wrappedView: wrappedView,
      context.coordinator
    )
    // viewController.updateContentSize()
    return viewController
  }
  
  func updateNSViewController(_ viewController: KSV_ScrollViewController<Content>, context: Context) {
    // viewController.udateContentSize()
  }
  
  func makeCoordinator() -> KSV_RepresentableCoordinator<Content> {
    KSV_RepresentableCoordinator(self)
  }
}
class KSV_RepresentableCoordinator<Content: View>: NSObject {
  var parentRepresentable: KSV_ViewControllerRepresentable<Content>
  init(_ parentRepresentable: KSV_ViewControllerRepresentable<Content>) {
    self.parentRepresentable = parentRepresentable
  }
}

#endif


