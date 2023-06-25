//
//  File.swift
//
//
//  Created by cms on 9/1/22.
//

import Foundation
import SwiftUI


// import OrderedCollections
// var DebugBordersLevels = OrderedDictionary<String, DebugBorderLevel>() {
//   didSet {
//     if false {
//       LLog("🔲 -- DebugBordersLevels Update -- 🔲")
//       DebugBordersLevels.forEach {
//         LLog("\($0.value.name): \($0.value.color)")
//       }
//     }
//   }
// }

// class DebugBorderLevel: Equatable, Hashable, ObservableObject {
//   static func == (lhs: DebugBorderLevel, rhs: DebugBorderLevel) -> Bool {
//     lhs.uuid == rhs.uuid
//
//   }
//   func hash(into hasher: inout Hasher) {
//     hasher.combine(uuid)
//   }
//   static let defaultWidths: [Double] = [ 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4.0]
//
//   var uuid = UUID()
//   init(_ name: String) {
//     self.name = name
//     self.color = AdAstraColor.BorderColors[wrapAroundForIndex: DebugBordersLevels.count] ?? AdAstraColor.gray
//     self.width = {
//       return
//       CGFloat(Self.defaultWidths[safeIndex: DebugBordersLevels.count-1] ??
//               Self.defaultWidths.last!)
//     }()
//   }
//   var name: String
//   var displayName: String {
//     // givenName.titleCasetoWordsWithSpaces()
//     return "displayName"
//   }
//   var color: AdAstraColor = AdAstraColor.gray
//   var width: CGFloat = 1
//
//   @Published
//   var isOn: Bool = true
//
//   var activeColor: Color {
//     if isOn {
//       return color.system
//     } else {
//       return Color.clear
//     }
//   }
// }





import os.log

public struct DebugBorderNamesKey: PreferenceKey {
  public static var defaultValue: [DebugBorderRecord] = .empty // ["Borders:"]
  public static func reduce(value: inout [DebugBorderRecord], nextValue: () -> [DebugBorderRecord]) {
    // let newValue = nextValue()
    // value.append(contentsOf: newValue)

    let addingValue = nextValue()
    // Logger.llog("will add \(addingValue)")
    // value.append(contentsOf: addingValue)
    let updatedValue = value + addingValue
    value = updatedValue
    // Logger.llog("updated border names:")
    // Logger.llog("\(value)")
  }
}



