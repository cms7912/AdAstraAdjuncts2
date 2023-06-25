//
//  File.swift
//
//
//  Created by cms on 9/1/22.
//

import Foundation
import SwiftUI

public struct DebugBorderRecord: Equatable, Hashable {
  var viewName: String = ""
  let viewID: UUID = UUID()
  var active: Bool?
  var color: Color = Color.primary
  var width: CGFloat = 1

  public static func == (lhs: DebugBorderRecord, rhs: DebugBorderRecord) -> Bool {
    lhs.viewID == rhs.viewID
  }

  var activeColor: Color {
    if DebugBordersViewModel.show(self) {
      return color
    } else {
      return Color.clear
    }
  }
}

struct DebugBordersModifier: ViewModifier {
  @EnvironmentObject var debugBordersVM: DebugBordersViewModel
  @State var border: DebugBorderRecord

  var highlighted: Bool { debugBordersVM.highlightBorder == border }
  @State private var marchingAntsPhase: CGFloat = 0

  var borderIsActive: Bool {
    if DebugBordersViewModel.AllBordersDefaultHidden {
      if let nameAsDate = DateFormatter().date(from: border.viewName),
         nameAsDate.timeIntervalSinceNow < TimeInterval(24 * 60 * 60)
      {
        // if the name is actually a date, and date is today, then return true
        return true
      }
      return border.active.nilIsFalse
    } else {
      return border.active.nilIsTrue
    }
  }

  var renderedActive: Bool { (borderIsActive ||
      DebugBordersViewModel.shared.selectedBordersList.contains(border) &&
      highlighted.isFalse) }


  var renderedColor: Color { renderedActive ? border.color : .clear }

  var renderedWidth: CGFloat { renderedActive ? border.width : 0 }
  var borderColor: Color { renderedColor }


  func body(content: Content) -> some View {Group{
    if DebugBordersViewModel.DebugBordersOn.isOff {
      content
    } else {
      content
        .border(borderColor,
                width: renderedWidth)
        .background(
          Color.clear
            .preference(key: DebugBorderNamesKey.self, value: [border])
        )
        .overlay(
          Group{
            EmptyView()
            if highlighted {
              Rectangle()
                .strokeBorder(border.color,
                              style:
                              StrokeStyle(lineWidth: border.width,
                                          dash: [10],
                                          dashPhase: marchingAntsPhase))
                .onAppear {
                  withAnimation(.linear.repeatCount(100)) {
                    marchingAntsPhase -= 20
                  }
                }
              //
            }
          }
        )
    }
  }}
}

public extension View {
  #if DEBUG

  func debugBorder(
    if active: Bool? = nil,
    _ viewName: String = #function,
    _ optionalColor: Color? = nil,
    _ optionalWidth: CGFloat? = nil
  ) -> some View {
    Group {
      // if HighlightDebug.feature.showDebugBorders {
      if DebugBordersViewModel.DebugBordersOn {
        self.modifier(
          DebugBordersModifier(border:
            DebugBorderRecord(
              viewName: viewName,
              active: active,
              color: optionalColor ?? automaticColor(),
              width: optionalWidth ?? 1
            )
          )
        )
      } else {
        self
      }
    }
  }

  internal func automaticColor() -> Color {
    // (AdAstraColor.BorderColors[wrapAroundForIndex: DebugBordersViewModel.shared.bordersList.count] ?? AdAstraColor.gray).system
//    (AdAstraColor.BorderColors.randomElement() ?? .gray).system
    Color.gray
  }


  #else

  internal func debugBorder(
    if _: Bool? = nil,
    _: String = #function,
    _: Color? = nil,
    _: CGFloat? = nil
  ) -> some View {
    self
  }

  #endif

  func debugBorder(_ color: Color, viewName: String = #function) -> some View {
    debugBorder(if: nil, viewName, color, nil)
  }

  func debugBorder(_ color: Color, _ border: CGFloat? = nil, viewName: String = #function) -> some View {
    debugBorder(if: nil, viewName, color, border)
  }

  func debugBorder(_ viewName: String = #function, _ color: Color? = nil, _ border: CGFloat? = nil) -> some View {
    debugBorder(if: nil, viewName, color, border)
  }

  func debugBorder(_ active: Bool?, _ color: Color? = nil, _ border: CGFloat? = nil, _ viewName: String = #function) -> some View {
    debugBorder(if: active, viewName, color, border)
  }

  func debugBorder(_ active: Bool?, _ viewName: String = #function, _ color: Color? = nil, _ border: CGFloat? = nil) -> some View {
    debugBorder(if: active, viewName, color, border)
  }
}

