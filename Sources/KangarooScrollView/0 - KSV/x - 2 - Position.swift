//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation
#if DEBUG_X
typealias KPosition = KangarooPosition
public class KangarooPosition: Equatable, Hashable, Identifiable, ObservableObject {
	public static func == (lhs: KangarooPosition, rhs: KangarooPosition) -> Bool {
		lhs.id == rhs.id
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(id)
	}

	public let id: String = UUID().uuidString
	var relativePosition: CGFloat?
	public var absolutePosition: CGFloat? {
		didSet{ update() }
	}
	var caliperRadius: CGFloat?
	var infiniteCaliper: Bool = false

	public init( absolutePosition: CGFloat? = nil,
							 relativePosition: CGFloat? = nil,
							 cardinalPosition: DivotAlignmentProtocol? = nil,
							 caliperRadius: CGFloat = .infinity) {

		if let cardinalPosition = cardinalPosition as? HorizontalAlignment {
			// Horizontal:
			switch cardinalPosition {
				case .leading:
					self.relativePosition = 0
				case .center:
					self.relativePosition = 0.5
				case .trailing:
					self.relativePosition = 1.0
				default: break
			}
		} else if let cardinalPosition = cardinalPosition as? VerticalAlignment {
			// Vertical:
			switch cardinalPosition {
				case .top:
					self.relativePosition = 0
				case .center:
					self.relativePosition = 0.5
				case .bottom:
					self.relativePosition = 1.0
				default: break
			}
		} else if relativePosition.isNotNil {
			self.relativePosition = relativePosition
		} else if let absolutePosition = absolutePosition {
			self.absolutePosition = absolutePosition
			// } else {
			// 	fatalError()
		}
		if caliperRadius.isInfinite {
			self.infiniteCaliper = true
			self.caliperRadius = 0
		} else {
			self.caliperRadius = caliperRadius

		}
		actualPosition = -7912

		_residingViewDirection = Binding(get:{ Axis.Set.horizontal }, set: {_ in })
	}
	// var actualPosition: CGFloat?
	private var subscriptions = Set<AnyCancellable>()

	@Published public var actualPosition: CGFloat
	//  var actualPositionBinding: Binding<CGFloat> {
	//    Binding(get: {self.actualPosition}, set: { self.actualPosition = $0 })
	//  }

	@Binding var residingViewDirection: Axis.Set
	var residingViewLength: CGFloat?
	var lastUpdatedUsingLength: CGFloat?
	//  func update(_ length: CGFloat) -> Self {
	//    if lastUpdatedUsingLength == length { return self }
	//    if let absolutePosition = absolutePosition {
	//      actualPosition = absolutePosition
	//    } else if let relativePosition = relativePosition {
	//      actualPosition = (length * relativePosition)
	//    }
	//    lastUpdatedUsingLength = length
	//    return self
	//  }
	func update(){
		if residingViewLength.isNotNil { return } // should also test direction changes

		var updatedPosition: CGFloat?
		if let absolutePosition = absolutePosition {
			updatedPosition = absolutePosition
		} else if let relativePosition = relativePosition {
			updatedPosition = ((residingViewLength ?? 0) * relativePosition)
		}
		if let updatedPosition = updatedPosition,
			 updatedPosition != actualPosition {
			actualPosition = updatedPosition
		}
		//lastUpdatedUsingLength = residingViewLength
	}

	func initiateResidingViewObservation(
		direction: Binding<Axis.Set>,
		size: Published<CGSize>.Publisher){
			_residingViewDirection = direction
			//_residingViewSize = size
			// direction
			// 	.sink { [weak self] newValue in
			// 		self?.update() }
			// 	.store(in: &subscriptions)

			size
				.sink { [weak self] newValue in
					guard let self = self else { return }
					self.residingViewLength = newValue.for(self.residingViewDirection)

																									self.update()

				}
				.store(in: &subscriptions)

		}

	func measureTo(_ divot: KangarooPosition, with traslation: CGFloat) -> CGFloat? {

		let baseDist: CGFloat = abs((self.actualPosition + traslation) - divot.actualPosition)

		if self.infiniteCaliper { return baseDist }

		let sumCalipers =
		self.caliperRadius.as0IfNil + divot.caliperRadius.as0IfNil

		guard baseDist <= sumCalipers else { return nil } // not within each other's calipers, 'nil' to ensure this divot isnt used

		let caliperedDist: CGFloat = baseDist - sumCalipers
		return caliperedDist
	}
}

extension KangarooPosition {

	static var StickyEnds: [any Map] {
		let endNotches = [
			KangarooPosition(relativePosition: 0.0, caliperRadius: 20),
			KangarooPosition(relativePosition: 1.0, caliperRadius: 20)
		]

		let endDivots = [
			KangarooPosition(relativePosition: 0.0, caliperRadius: 20),
			KangarooPosition(relativePosition: 1.0, caliperRadius: 20)
		]
		return [

			GenericMap(
				notchStart: .constant(0),
				notchInterval: .constant(0),
				notchCaliperRadius: .constant(20),
				divotStart: .constant(0),
				divotInterval: .constant(0),
				divotCaliperRadius: .constant(20)),

			GenericMap(
				notchStart: .constant(1),
				notchCount: .constant(1),
				notchCaliperRadius: .constant(20),
				divotStart: .constant(1),
				divotCount: .constant(1),
				divotCaliperRadius: .constant(20))

		]
	}

}

#endif 
