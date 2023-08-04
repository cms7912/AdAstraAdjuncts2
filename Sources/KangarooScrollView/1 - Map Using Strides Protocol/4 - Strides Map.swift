//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
import Combine
import SwiftUI
import AdAstraExtensions

public class GenericStridesMap: NotchStridesMapProtocol, DivotStridesMapProtocol {
	lazy public var llogPrefix = { "🦘\( ksvScrollManager?.scrollViewName ?? "") " }()
  public var llogIsEnabled: Bool { KSVScrollManager.LLogIsEnabled(for: ksvScrollManager?.scrollViewName) && KSVDebug.feature.logKangarooScrollView }

	// Map Protocol Requirements -----
	weak public var ksvScrollManager: KSVScrollManager? {
		didSet {
			guard ksvScrollManager.isNotNil else { assert(false); return }
			// after setting, this variable should never be changed
			setupPaneSubscription()
			setupContentSubscription()
		}
	}
	public var mapID: UUID = UUID()
	// ----- Map Protocol Requirements


	// MapUsingStrides Protocol Requirements -----
	public var notchStrideMetadata: StrideMetadata
	public var divotStrideMetadata: StrideMetadata


	public var notchPositionsStore: [CGFloat]? {
		willSet{
			llog ("notchPositionsStoreWillSet: \(newValue.isNil ? "'nil'" : newValue!.count.description )")
			_ = true
		}
		didSet {
      llog ("notchPositionsStoreDidSet: \(notchPositionsStore.isNil ? "'nil'" : notchPositionsStore!.count.description )")
			_ = true
		}
	}
	public var divotPositionsStore: [CGFloat]? {
		willSet{
      llog ("divotPositionsStoreWillSet: \(newValue.isNil ? "'nil'" : newValue!.count.description )")
			llog(newValue.dd)
			_ = true
		}
		didSet {
      llog ("divotPositionsStoreDidSet: \(divotPositionsStore.isNil ? "'nil'" : divotPositionsStore!.count.description )")
			_ = true
		}
	}

	public subscript(notchCaliper index: Int) -> CGFloat { notchCaliperRadius }
	public subscript(divotCaliper index: Int) -> CGFloat { divotCaliperRadius }


	public var subscriptions = Set<AnyCancellable>()
	// ----- Map Protocol Requirements


	@Binding var notchCaliperRadius: CGFloat
	@Binding var divotCaliperRadius: CGFloat

	public init(
		notchStart: Binding<CGFloat>,
		notchInterval: Binding<CGFloat>? = nil,
		notchCount: Binding<CGFloat>? = nil,
		notchCaliperRadius: Binding<CGFloat> = .constant(.infinity),

		divotStart: Binding<CGFloat>,
		divotInterval: Binding<CGFloat>? = nil,
		divotCount: Binding<CGFloat>? = nil,
		divotCaliperRadius: Binding<CGFloat> = .constant(1)

	){

		if let notchInterval = notchInterval {
			self.notchStrideMetadata =
			AbsoluteStrideMetadata(
				firstStop: notchStart,
				stopInterval: notchInterval)
		} else if let notchCount = notchCount {
			self.notchStrideMetadata =
			RelativeStrideMetadata(
				firstStop: notchStart,
				stopCount: notchCount)
		} else {
			self.notchStrideMetadata = FailedStride()
		}

		self._notchCaliperRadius = notchCaliperRadius


		if let divotInterval = divotInterval {
			self.divotStrideMetadata =
			AbsoluteStrideMetadata(
				firstStop: divotStart,
				stopInterval: divotInterval)
		} else if let divotCount = divotCount {
			self.divotStrideMetadata =
			RelativeStrideMetadata(
				firstStop: divotStart,
				stopCount: divotCount)
		} else {
			self.divotStrideMetadata = FailedStride()
		}
		self._divotCaliperRadius = divotCaliperRadius


	}

}

