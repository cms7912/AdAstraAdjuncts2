//
//  File.swift
//  File
//
//  Created by CMS on 12/9/21.
//

import Foundation
import SwiftUI
//import AdAstraBridgingNSExtensions

// helpful: https://sarunw.com/posts/dark-color-cheat-sheet/

public extension Color{
  static let appPrimary = Color.systemBlue


  // MARK: - - iOS

  #if os(iOS)

  static var label: Color {
    return Color(UIColor.label)
  }

  static var secondaryLabel: Color {
    return Color(UIColor.secondaryLabel)
  }

  static var tertiaryLabel: Color {
    return Color(UIColor.tertiaryLabel)
  }

  static var quaternaryLabel: Color {
    return Color(UIColor.quaternaryLabel)
  }

  static var systemFill: Color {
    return Color(UIColor.systemFill)
  }

  static var aaSecondarySystemFill: Color {
    return Color(UIColor.secondarySystemFill)
  }

  static var aaTertiarySystemFill: Color {
    return Color(UIColor.tertiarySystemFill)
  }

  static var aaQuaternarySystemFill: Color {
    return Color(UIColor.quaternarySystemFill)
  }

  static var aaSystemBackground: Color {
    return Color(UIColor.systemBackground)
  }

  static var aaSecondarySystemBackground: Color {
    return Color(UIColor.secondarySystemBackground)
  }

  static var aaTertiarySystemBackground: Color {
    return Color(UIColor.tertiarySystemBackground)
  }

  static var aaSystemGroupedBackground: Color {
    return Color(UIColor.systemGroupedBackground)
  }

  static var aaSecondarySystemGroupedBackground: Color {
    return Color(UIColor.secondarySystemGroupedBackground)
  }

  static var aaTertiarySystemGroupedBackground: Color {
    return Color(UIColor.tertiarySystemGroupedBackground)
  }

  static var systemRed: Color {
    return Color(UIColor.systemRed)
  }

  static var systemBlue: Color {
    return Color(UIColor.systemBlue)
  }

  static var systemPink: Color {
    return Color(UIColor.systemPink)
  }

  static var systemTeal: Color {
    return Color(UIColor.systemTeal)
  }

  static var systemGreen: Color {
    return Color(UIColor.systemGreen)
  }

  static var systemIndigo: Color {
    return Color(UIColor.systemIndigo)
  }

  static var systemOrange: Color {
    return Color(UIColor.systemOrange)
  }

  static var systemPurple: Color {
    return Color(UIColor.systemPurple)
  }

  static var systemYellow: Color {
    return Color(UIColor.systemYellow)
  }

  static var systemGray: Color {
    return Color(UIColor.systemGray)
  }

  static var systemGray2: Color {
    return Color(UIColor.systemGray2)
  }

  static var systemGray3: Color {
    return Color(UIColor.systemGray3)
  }

  static var systemGray4: Color {
    return Color(UIColor.systemGray4)
  }

  static var systemGray5: Color {
    return Color(UIColor.systemGray5)
  }

  static var systemGray6: Color {
    return Color(UIColor.systemGray6)
  }

  // https://medium.com/@masamichiueta/bridging-uicolor-system-color-to-swiftui-color-ef9

  // CMRS added:
  static var aaPlaceholderText: Color {
    return Color(UIColor.placeholderText)
  }

  static var aaSeparator: Color {
    return Color(UIColor.separator)
  }

  static var aaOpaqueSeparator: Color {
    return Color(UIColor.opaqueSeparator)
  }

  // MARK: - - macOS

  #elseif os(macOS)

  //    static let offWhite = Color(red: 215 / 255, green: 215 / 255, blue: 225 / 255)
  static let offWhite = NSColor(white: 225 / 255, alpha: 1.0)

  static var label: Color {
    return Color(NSColor.label)
  }

  static var secondaryLabel: Color {
    return Color(NSColor.secondaryLabel)
  }

  static var tertiaryLabel: Color {
    return Color(NSColor.tertiaryLabel)
  }

  static var quaternaryLabel: Color {
    return Color(NSColor.aaQuaternaryLabel)
  }

  static var systemFill: Color {
    return Color(NSColor.aaSystemFill)
  }

  static var aaSecondarySystemFill: Color {
    return Color(NSColor.aaSecondarySystemFill)
  }

  static var aaTertiarySystemFill: Color {
    return Color(NSColor.aaTertiarySystemFill)
  }

  static var aaQuaternarySystemFill: Color {
    return Color(NSColor.aaQuaternarySystemFill)
  }

  static var aaSystemBackground: Color {
    return Color(NSColor.aaSystemBackground)
  }

  static var aaSecondarySystemBackground: Color {
    return Color(NSColor.aaSecondarySystemBackground)
  }

  static var aaTertiarySystemBackground: Color {
    return Color(NSColor.aaTertiarySystemBackground)
  }

  static var aaSystemGroupedBackground: Color {
    return Color(NSColor.aaSystemGroupedBackground)
  }

  static var aaSecondarySystemGroupedBackground: Color {
    return Color(NSColor.aaSecondarySystemGroupedBackground)
  }

  static var aaTertiarySystemGroupedBackground: Color {
    return Color(NSColor.aaTertiarySystemGroupedBackground)
  }

  static var systemRed: Color {
    return Color(NSColor.systemRed)
  }

  static var systemBlue: Color {
    return Color(NSColor.systemBlue)
  }

  static var systemPink: Color {
    return Color(NSColor.systemPink)
  }

  static var systemTeal: Color {
    return Color(NSColor.systemTeal)
  }

  static var systemGreen: Color {
    return Color(NSColor.systemGreen)
  }

  static var systemIndigo: Color {
    return Color(NSColor.systemIndigo)
  }

  static var systemOrange: Color {
    return Color(NSColor.systemOrange)
  }

  static var systemPurple: Color {
    return Color(NSColor.systemPurple)
  }

  static var systemYellow: Color {
    return Color(NSColor.systemYellow)
  }

  static var systemGray: Color {
    return Color(NSColor.systemGray)
  }

  static var systemGray2: Color {
    return Color(NSColor.aaSystemGray2)
  }

  static var systemGray3: Color {
    return Color(NSColor.aaSystemGray3)
  }

  static var systemGray4: Color {
    return Color(NSColor.aaSystemGray4)
  }

  static var systemGray5: Color {
    return Color(NSColor.aaSystemGray5)
  }

  static var systemGray6: Color {
    return Color(NSColor.aaSystemGray6)
  }

  // https://medium.com/@masamichiueta/bridging-NSColor-system-color-to-swiftui-color-ef9


  // CMRS added:
  static var placeholderText: Color {
    return Color(NSColor.placeholderText)
  }

  static var separator: Color {
    return Color(NSColor.aaSeparator)
  }

  static var opaqueSeparator: Color {
    return Color(NSColor.aaOpaqueSeparator)
  }



  #endif
}
