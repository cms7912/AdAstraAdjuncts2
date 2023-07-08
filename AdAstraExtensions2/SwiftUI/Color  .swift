//
//  File.swift
//  File
//
//  Created by cms on 10/21/21.
//

import Foundation
import SwiftUI

// #if canImport(AdAstraBridgingByMask)
// import AdAstraBridgingByMask
// #endif


public extension Color {
  static var isLightMode: Bool {
    #if os(iOS)
    var light: Bool = true
    _ = UIColor{ light = ($0.userInterfaceStyle == .light); return .black }
    return light
    #elseif os(macOS)
    NSApp.effectiveAppearance.name == .aqua

    #endif
  }

  static var isDarkMode: Bool { !isLightMode }
}

public extension Color {
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    let length = hexSanitized.count

    var rgb: UInt32 = 0

    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0


    guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0

    } else if length == 8 {
      r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x0000_00FF) / 255.0

    } else {
      return nil
    }

    self.init(red: r, green: g, blue: b, opacity: a)

    // https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift/
  }

  var asHexValue: String? {
    #if os(iOS)
    let cgColor = UIColor(self).cgColor
    #elseif os(macOS)
    let cgColor = NSColor(self).cgColor
    #endif

    guard let components = cgColor.components, components.count >= 3 else { return nil }

    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)

    if components.count >= 4 {
      a = Float(components[3])
    }

    // if alpha {
    return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    // } else {
    // return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    // }
    // https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift/
  }
}


public extension Color {
  static var random: Color {
    Color(.displayP3,
          red: .random(in: 0 ... 1),
          green: .random(in: 0 ... 1),
          blue: .random(in: 0 ... 1),
          opacity: .random(in: 0 ... 1))
  }
}


// Platform Color
public extension Color {
  #if os(macOS)
  init(_ platformColor: NSColor) {
    if #available(macOS 12.0, *) {
      self.init(nsColor: platformColor)
    } else {
      self.init(hue: platformColor.hueComponent,
                saturation: platformColor.saturationComponent,
                brightness: platformColor.brightnessComponent)
    }
  }

  var platformColor: NSColor {
    NSColor(self).usingColorSpace(.extendedSRGB) ?? NSColor(self)
  }

  #elseif os(iOS)
  init(_ platformColor: UIColor) {
    if #available(iOS 15, macCatalyst 15.0, *) {
      self.init(uiColor: platformColor)
    } else {
      // self.init(hue: platformColor.hsba.hue,
      //           saturation: platformColor.hsba.saturation,
      //           brightness: platformColor.hsba.brightness)
      self.init(uiColor: platformColor)
    }
  }

  var platformColor: UIColor {
    UIColor(self)
  }
  #endif
}

public extension SwiftUI.Image {
  #if os(iOS)
  init?(_ data: Data) {
    guard let image = UIImage(data: data) else { return nil}
    self.init(uiImage: image)
  }

  init(platformImage: UIImage) {
    // guard let image = platformImage else { return nil}
    self.init(uiImage: platformImage)
  }

  #elseif os(macOS)
  init?(_ data: Data) {
    guard let image = NSImage(data: data) else { return nil }
    self.init(nsImage: image)
  }

  init(platformImage: NSImage) {
    self.init(nsImage: platformImage)
  }
  #endif
}


public extension Color {
  static var Assert: Color {
    assertionFailure()
    return Color.gray
  }
}


// public extension Shape {
//   func fillAndStroke<C: ShapeStyle>(_ fillContent: C, _ lineWidth: CGFloat, _ lineContent: C? = nil) -> some View {
//     self
//       .stroke(lineContent ?? fillContent, lineWidth: lineWidth)
//       .background(fillContent)
//     // S.clipShape(Self(cornerRadius: 20, style: .continuous))
//     // S.clipShape(Self(cornerRadius: sel ))
//     // )
//
//   }
// }










extension Color: Codable {
  init(hex2: String) {
    let rgba = hex2.toRGBA()

    self.init(.sRGB,
              red: Double(rgba.r),
              green: Double(rgba.g),
              blue: Double(rgba.b),
              opacity: Double(rgba.alpha))
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let hex = try container.decode(String.self)
    self.init(hex2: hex)
//    LLog("Successfully decoded color")
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(toHex)
//    LLog("Successfully encoded color")
  }

  var toHex: String? {
    return toHex()
  }

  func toHex(alpha: Bool = false) -> String? {
    #if os(iOS)
    let cgColor = UIColor(self).cgColor
    #elseif os(macOS)
    let cgColor = NSColor(self).cgColor
    #endif

    guard let components = cgColor.components, components.count >= 3 else {
      return nil
    }

    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)

    if components.count >= 4 {
      a = Float(components[3])
    }

    if alpha {
      return String(format: "%02lX%02lX%02lX%02lX",
                    lroundf(r * 255),
                    lroundf(g * 255),
                    lroundf(b * 255),
                    lroundf(a * 255))
    } else {
      return String(format: "%02lX%02lX%02lX",
                    lroundf(r * 255),
                    lroundf(g * 255),
                    lroundf(b * 255))
    }
  }
}

extension String {
  func toRGBA() -> (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
    var hexSanitized = trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0

    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0

    let length = hexSanitized.count

    Scanner(string: hexSanitized).scanHexInt64(&rgb)

    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
    } else if length == 8 {
      r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x0000_00FF) / 255.0
    }

    return (r, g, b, a)
  }
}









//
//public extension Color {
//  static var SystemGrayLevels: [Color] = [
//    .systemGray,
//    .systemGray2,
//    .systemGray3,
//    .systemGray4,
//    .systemGray5,
//    .systemGray6,
//  ]
//}
