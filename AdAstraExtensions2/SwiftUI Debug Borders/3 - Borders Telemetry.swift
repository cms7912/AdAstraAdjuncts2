
//
//  File 2.swift
//
//
//  Created by cms on 9/1/22.
//

import Foundation
import SwiftUI

/*
 public struct DebugBordersEnvironmentKey: EnvironmentKey {
 	// this is the default value that SwiftUI will fallback to if you don't pass the object
 	public static var defaultValue: DebugBordersViewModel = .init()
 }

 public extension EnvironmentValues {
 	// the new key path to access your object (\.object)
 	var debugBordersViewModel: DebugBordersViewModel {
 		get { self[DebugBordersEnvironmentKey.self] }
 		set { self[DebugBordersEnvironmentKey.self] = newValue }
 	}
 }

 public extension View {
 	// this is just an elegant wrapper to set your object into the environment
 	func debugBordersViewModel(_ value: DebugBordersViewModel) -> some View {
 		environment(\.debugBordersViewModel, value)
 	}
 }
 */

public class DebugBordersViewModel: ObservableObject {
  public static var shared = DebugBordersViewModel()
  #if DEBUG // && !SANDBOX
  public static var DebugBordersOn: Bool = true
 // public static var DebugBordersOn: Bool = false
  #else
  public static var DebugBordersOn: Bool = false
  #endif

  public static var AllBordersDefaultHidden: Bool = false {
    willSet {
      Self.shared.objectWillChange.send()
    }
  }

  public static var ShowListToggle: Bool = false

  @Published public var bordersList: [DebugBorderRecord] = .empty
  // var bordersListNamesUsed: [String] = .empty

  @Published var selectedBordersList: [DebugBorderRecord] = .empty
  @Published var deselectedBordersList: [DebugBorderRecord] = .empty
  @Published var highlightBorder: DebugBorderRecord = DebugBorderRecord()

  static func show(_ record: DebugBorderRecord) -> Bool {
    DebugBordersViewModel.shared.selectedBordersList.contains(record)
  }

  func Reset() {
    bordersList.removeAll()
    highlightBorder = DebugBorderRecord()
  }
}



public struct DebugBordersTelemetry: View {
  public init() { }
  public static var ShowListRendered: Bool {
    DebugBordersViewModel.DebugBordersOn && DebugBordersViewModel.ShowListToggle
  }


  @EnvironmentObject var debugBordersVM: DebugBordersViewModel
  // @EnvironmentObject var debug: HighlightDebug
  public var body: some View {
    if DebugBordersTelemetry.ShowListRendered {
      ScrollView { VStack {
        Text("=Debug Borders=")
          .modifiersFor{view in Group{
            if #available(iOS 16.0, macOS 13.0, *) {
              view
                .bold(DebugBordersViewModel.AllBordersDefaultHidden.isOff)
            } else {
              view
            }
          } }
          .onTapGesture(count: 2) { headingTappedTwice() }
          .onTapGesture(count: 3) { headingTappedThreeTimes() }

        ForEach(debugBordersVM.bordersList, id: \.self) { border in
          DebugBordersTelemetryTextLine(border: border)
        }
      } }
      .font(.caption2)
      .background(Color.gray.opacity(0.50))
      // .background(Color.secondarySystemGroupedBackground.opacity(1.00))
      // .listRowBackground(Color.secondarySystemGroupedBackground.opacity(0.50))
      .frame(maxWidth: 100, maxHeight: 200)
      .fixedSize(horizontal: false, vertical: true)
      // .frame(maxWidth: 100)
    } else { EmptyView() }
  }

  func headingTappedTwice() {
    DebugBordersViewModel.AllBordersDefaultHidden.toggle()
    if DebugBordersViewModel.AllBordersDefaultHidden {
      DebugBordersViewModel.shared.Reset()
    }
  }

  func headingTappedThreeTimes() {
    DebugBordersViewModel.DebugBordersOn.toggle()
    if DebugBordersViewModel.DebugBordersOn.isOff {
      DebugBordersViewModel.shared.Reset()
    }
  }
}

struct DebugBordersTelemetryTextLine: View {
  @EnvironmentObject var debugBordersVM: DebugBordersViewModel
  @State var border: DebugBorderRecord
  var nameColor: Color {
    if border.activeColor != .clear {
      return border.activeColor
    }
    return Color.secondary
  }

  // var nameBackground: ListItemTint? {
  //   debugBordersVM.selectedBordersList.contains(borderName) ? ListItemTint.monochrome : nil }
  var nameBackground: Color? {
    debugBordersVM.selectedBordersList.contains(border) ? nil : nil
  }

  var nameStrikethrough: Bool {
    false
    // debugBordersVM.deselectedBordersList.contains(borderName)
  }

  var body: some View {
    Text(border.viewName)
      .font(.caption2)
      .modifiersFor{view in Group{
        if #available(iOS 16.0, macOS 13.0, *) {
          view.bold(debugBordersVM.selectedBordersList.contains(self.border))
        } else {
          view
        }
      } }
      .foregroundColor(nameColor)
      .background(nameBackground)
      // .strikethrough(nameStrikethrough)
      .onTapGesture { tapped() }
      .onHover{ hovering in
        if hovering {
          debugBordersVM.highlightBorder = border
        } else {
          if debugBordersVM.highlightBorder == border {
            debugBordersVM.highlightBorder = DebugBorderRecord()
          }
        }
      }
    // .listItemTint(ListItemTint.monochrome)
    // .listItemTint(nameBackground)
  }

  func tapped() {
    if debugBordersVM.selectedBordersList.contains(border) {
      // deselecting
      // debugBordersVM.selectedBordersList = debugBordersVM.selectedBordersList.compactMap{ i in
      // (i != record) ? i : nil }
      debugBordersVM.selectedBordersList.removeAll{ $0 == border }
    } else {
      // selecting
      debugBordersVM.selectedBordersList.append(border)
    }
  }
}


struct DebugBordersAndTelemetry: ViewModifier {
  @StateObject var debugBordersViewModel = DebugBordersViewModel.shared

  @ViewBuilder
  func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottomTrailing) { DebugBordersTelemetry() }
      .onPreferenceChange(DebugBorderNamesKey.self) { newList in
        debugBordersViewModel.bordersList = newList }
      .environmentObject(debugBordersViewModel)
  }
}

public extension View {
  func injectDebugBordersAndTelemetry() -> some View {
    Group{
      if DebugBordersViewModel.DebugBordersOn {
        self
          .modifier(DebugBordersAndTelemetry())
      } else {
        self
      }
    }
  }
}
