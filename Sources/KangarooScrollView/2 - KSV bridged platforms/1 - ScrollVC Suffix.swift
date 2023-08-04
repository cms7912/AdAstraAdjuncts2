//
//  File.swift
//  
//
//  Created by cms on 3/22/22.
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


class KSV_ScrollViewController<Content: View>: KSV_UniversalSuffixScrollViewController<Content> { }
/// convenience caller

class KSV_UniversalSuffixScrollViewController<Content: View>: KSV_PlatformScrollViewController<Content>, KSVScrollVCDelegate {
  
  lazy var llogPrefix = { "🦘\( ksvScrollManager.scrollViewName ?? "") " }()
  var llogIsEnabled: Bool { KSVScrollManager.LLogIsEnabled(for: ksvScrollManager.scrollViewName) && KSVDebug.feature.logKangarooScrollView_ViewController ?? false }
  
  
  var coordinator: KSV_RepresentableCoordinator<Content>
  init(
    ksvScrollManager: KSVScrollManager,
    gvm: KangarooScrollViewGenericViewModel,
    ksvProxy: Binding<KangarooScrollViewProxy>,
    wrappedView: @escaping (KangarooScrollViewProxy) -> Content,
    _ coordinator: KSV_RepresentableCoordinator<Content>){
      //			self.ksvScrollManager = ksvScrollManager
      //self.gvm = gvm
      //self._ksvProxy = ksvProxy
      self.coordinator = coordinator
      super.init(ksvScrollManager: ksvScrollManager,
                 gvm: gvm,
                 ksvProxy: ksvProxy,
                 wrappedView: wrappedView)
			ksvScrollManager.scrollVCDelegate = self
    }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
#if os(iOS)
  // newHostController.view.invalidateIntrinsicContentSize()
  // newHostController.view.translatesAutoresizingMaskIntoConstraints = false
#elseif os(macOS)
  // newHostController.view.invalidateIntrinsicContentSize()
  // newHostController.view.translatesAutoresizingMaskIntoConstraints = false
#endif
  
  override func loadView() {
    // self.view = UINSView() // the view being controlled
    // self.view.addSubviewWithAnchorConstraints(stageView)
		self.view = stageView
    // https://stackoverflow.com/questions/65669250/swiftui-nspagecontroller-in-nsviewcontrollerrepresentable-crashes
  }

  override func viewDidLoad(){
    super.viewDidLoad()
		platformViewDidLoad()
		extendedViewDidLoad()
		stageView.addSubviewWithAnchorConstraints(theScrollView)
  }
  
	override func universalViewDidAppear() { extendedUniversalViewDidAppear() }

	func move(by deltaShift: CGFloat) { platformMove(by: deltaShift) }

  
}
