//
//  File.swift
//
//
//  Created by cms on 1/2/22.
//

import AdAstraExtensions
import UniformTypeIdentifiers

final class KSVDebug: NSObject, AdAstraDebugProtocol {
  public static var feature = KSVDebug()
  #if DEBUG
  // static var ENABLED: Bool { true }
  static var Enabled: Bool = true
  #else
  // static var ENABLED: Bool { false }
  static var Enabled: Bool = false
  #endif
  static var f = false


  static var LogKangarooScrollView: Bool?
  // = Enabled
  lazy var logKangarooScrollView: Bool = Self.LogKangarooScrollView ?? false
  { willSet { Self.LogKangarooScrollView = newValue } }

  static var ENABLED_KSV: Bool { LogKangarooScrollView ?? false }
  // var ENABLED_KSV: Bool { Self.ENABLED_KSV }

  var logKangarooScrollView_Manager = false
  // || Enabled
  var logKangarooScrollView_ViewController = false
  // || Enabled
}

import Foundation
import SwiftUI
import os.log
import AdAstraExtensions
import AdAstra_Addons
import AAUserInterface

// struct ContentView_Previews: PreviewProvider {
// 	static var previews: some View {
// 		KangarooScrollView_TestingContentView()
// 	}
// }

class ViewModel: ObservableObject {
  init() {
    assignKangarooMapArray()
  }

  // var direction: Axis.Set = .vertical
  @Published var direction: Axis.Set = .vertical
  @Published var pagingModeOn: Bool = false

  @Published var BoxCount: CGFloat = 40
  var BoxCountFloat: CGFloat { CGFloat(BoxCount) }
  // @Published var ViewSize: CGFloat = 1000
  @Published var BoxSize: CGFloat = 100

  // var BoxSize: CGFloat { pagingModeOn ?  ViewSize : unpagedBoxSize }
  // when pagingModeOn then set default box size to viewSize so box fills view

  @Published var KangarooMapArray: [any Map] = [any Map]()

  func assignKangarooMapArray() {
    /*
     // * Ends *
     let cardinalNotches = [
     	KangarooPosition(
     		absolutePosition: nil,
     		relativePosition: nil,
     		cardinalPosition: HorizontalAlignment.leading,
     		caliperRadius: 5),
     	KangarooPosition(
     		absolutePosition: nil,
     		relativePosition: nil,
     		cardinalPosition: HorizontalAlignment.trailing,
     		caliperRadius: 5)
     ]
     let cardinalDivots = [
     	KangarooPosition(cardinalPosition: HorizontalAlignment.leading, caliperRadius: 5),
     	KangarooPosition(cardinalPosition: HorizontalAlignment.trailing, caliperRadius: 5),
     ]


     // * Leading Edges *
     let leadingEdgeNotch = [
     	KangarooPosition(cardinalPosition: HorizontalAlignment.center, caliperRadius: .infinity)
     ]

     // via absolutePosition
     let leadingEdgeDivots: [KangarooPosition] =
     stride(from: 0, through: BoxSize*BoxCountFloat, by: BoxSize).map{
     	KangarooPosition(absolutePosition: $0, caliperRadius: 5)
     }

     // via relativePosition
     let leadingEdgeDivots2: [KangarooPosition] =
     stride(from: 0, through: 1, by: 1/BoxCountFloat).map{
     	KangarooPosition(relativePosition: $0, caliperRadius: 5)
     }


     // * Centers *
     let centerNotch = [
     KangarooPosition(cardinalPosition: HorizontalAlignment.center, caliperRadius: 20)
     ]

     // via absolutePosition
     let centerDivots: [KangarooPosition] =
     stride(from: BoxSize/2, to: BoxSize*BoxCountFloat, by: BoxSize).map{
     KangarooPosition(absolutePosition: $0, caliperRadius: 5)
     }

     // via relativePosition
     let centerDivots2: [KangarooPosition] =
     stride(from: (0.5/BoxCountFloat), to: 1, by: 1/BoxCountFloat).map{
     KangarooPosition(relativePosition: $0, caliperRadius: 5)
     }


     // * Tests *
     let testNotch = [
     KangarooPosition(relativePosition: 0.25, caliperRadius: .infinity)
     ]

     // via absolutePosition
     let testDivots: [KangarooPosition] =
     stride(from: BoxSize/2, to: BoxSize*BoxCountFloat, by: BoxSize).map{
     KangarooPosition(absolutePosition: $0, caliperRadius: 5)
     }
     let testDivot: [KangarooPosition] =
     [KangarooPosition(absolutePosition: 2000, caliperRadius: 5)]

     */
    let convenienceMap: any Map =
      GenericStridesMap(
        notchStart: .constant(0.5),
        // notchCount: .constant(0),
        notchCount: .constant(1),

        divotStart: .constant(0),
        // divotCount: .constant(CGFloat(BoxCount)))
        divotCount: Binding(get: { [weak self] in
          self?.BoxCount ?? 0
        }, set: { _ in })
      )

    KangarooMapArray = [
      // (cardinalNotches, cardinalDivots),
      // KangarooMap(leadingEdgeNotch, leadingEdgeDivots2)
      convenienceMap,
    ]
  }
}


public struct KangarooScrollView_TestingContentView: View {
  public init() { }

  public var body: some View {
    KSVContentView()
  }
}


struct KSVContentView: View {
  @StateObject var viewModel = ViewModel()
  @StateObject var dragonVM = DragonViewModel<BoxCard>(dragonDelegate: nil)
  // var direction: Axis.Set { viewModel.direction }

  @State var buttonSuccess: Bool = false
  @State var ksvProxy: KangarooScrollViewProxy?
  var body: some View {
    // NavigationView{
    //	Text("intentionally left blank")


    ZStack{
      // VStack{
      //
      // 	Spacer().frame(height: 100)
      // 	Button("Target Button"){
      // 		print("Success!")
      // 		buttonSuccess.toggle()
      // 	}
      // 	.background( buttonSuccess ? Color.systemPurple : Color.clear )
      //
      // 	Spacer()
      // }

      if true {
        KangarooScrollView(direction: $viewModel.direction,
                           KangarooMapArray: $viewModel.KangarooMapArray,
                           underScrollOverScrollPercentage: (0.10, 0),
                           debugMode: false) { ksvProxy in
          // ){
          // Color.gray
          // 		// ScrollView(.horizontal, showsIndicators: true){
          // ZStack(alignment: .topLeading) {
          BoxContainer(direction: $viewModel.direction, BoxCount: $viewModel.BoxCount)
            .opacity(0.8)
            .onAppear{
              self.ksvProxy = ksvProxy
            }
          // .border(Color.systemYellow, width: 1)
        }
        // .border(Color.systemPurple, width: 1)
      }
    }
    .toolbar{
      ToolbarItemGroup(placement: .navigation) {
        Toggle("Paging", isOn: $viewModel.pagingModeOn)

        Button("(v)") {
          ksvProxy?.withStableScroll{
            // withAnimation{
            viewModel.BoxSize -= 25
            // }
          }
        }
        Button("\(viewModel.BoxSize.asString())") { }
        Button("(^)") {
          ksvProxy?.withStableScroll{
            // withAnimation{
            viewModel.BoxSize += 25
            // }
          }
        }
      }
      ToolbarItemGroup(placement: .navigation) {
        Button("UpdateStop") {
          ksvProxy?.scrollToCenterAnchorAction()
        }
        Button("Scroll To Anchor, nil") {
          ksvProxy?.scrollViewProxy?.scrollTo("[.]", anchor: nil)
        }
        Button("Scroll To Anchor, .leading") {
          ksvProxy?.scrollViewProxy?.scrollTo("[<]", anchor: .leading)
        }
        Button("Scroll To Anchor, .center") {
          ksvProxy?.scrollViewProxy?.scrollTo("[v]", anchor: .center)
        }
        Button("Scroll To Anchor, .trailing") {
          ksvProxy?.scrollViewProxy?.scrollTo("[>]", anchor: .trailing)
        }

        Button("Scroll to Center Anchor") {
          ksvProxy?.scrollToCenterAnchor()
        }
        // }
      }
    }
    .background( // detail frame geometry
      GeometryReader { _ in
        Color.clear
        // .onChange(of: detailFrameGeometryProxy.size){ newSize in
        //	viewModel.ViewSize = newSize.for(viewModel.direction)
        // }
      }
    )

    //
    // 	// .frame(width: viewModel.ViewSize)
    // 	// .aframe(direction, viewModel.ViewSize)
    .environmentObject(viewModel)
    .environmentObject(dragonVM)
    // 	.animation(.default, value: viewModel.ViewSize)
    // 	// .animation(.default, value: viewModel.unpagedBoxSize) // this animates the changing of rectangles' sizes
    //
    // }
  }
}

struct BoxContainer: View {
  @Binding var direction: Axis.Set
  @Binding var BoxCount: CGFloat

  var body: some View {
    AStack(direction, spacing: 0) {
      ForEach(1 ... Int(BoxCount), id: \.self) {
        Box(number: $0)
      }
    }
  }
}

struct BoxCard: DragonCard {
  static func NormalizeChildrenSortOrder<DragonCard>(for _: DragonCard) { }

  typealias ID = UUID

  typealias SO = Double

  typealias Parent = BoxCard


  var objectID: UUID = UUID()
  var objectIDEncoded: NSSecureCoding { NSString(string: objectID.uuidString) }
  var objectParent: BoxCard? { nil }

  var sortOrder: Double {
    get {
      Double(0)
    }
    set { }
  }

  static var defaultSortOrder: Double { 0 }

  // static func NormalizeChildrenSortOrder(for: BoxCard) { }
}

struct Box: View {
  @EnvironmentObject var viewModel: ViewModel

  @State var opacity: CGFloat = 0.8

  @State var boxCard = BoxCard()
  var number: Int
  var body: some View {
    Group{
      RoundedRectangle(cornerRadius: 20)
        .fill((AdAstraColor.BorderColors[wrapAroundForIndex: number]?.system ?? Color.white).opacity(opacity))
        .onTapGesture {
          opacity = opacity > 0.5 ? 0.3 : 0.8
        }
        .aframe(viewModel.direction, viewModel.BoxSize)
        .overlay(
          ZStack(alignment: .bottomTrailing) {
            Color.clear
            Text(
              """
              \(number)
              \((CGFloat(number) * viewModel.BoxSize).asString())
              """)
          }
        )
        // .id( number == 10 ? "centerBar" : "none" )
        .animation(.default, value: viewModel.BoxSize) // this animates the changing of rectangles' sizes
      // if number == 10 {
      //    AnchorRectangle()
      //       .id("center")
      // }
    }
    // .dragonDrop(
    //   DragonViewModel.CardData(axis: .constant(.vertical),
    //                            selfCard: boxCard,
    //                            selfContentUTTType: UTType.text ,
    //                            droppableContentUTTypes: [UTType.text],
    //                            backgroundColor: Color.white)
    // )
  }
}



// struct AnchorRectangle: View {
//    var body: some View {
//       Rectangle()
//          .fill(Color.secondaryLabel)
//          .frame(width: 20, height: 20)
//    }
// }


