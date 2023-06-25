//
//  Swift File.swift
//  Swift File
//
//  Created by CMS on 10/29/21.
//

import Foundation
import SwiftUI
#if canImport(AdAstraBridgingByMask)
// import AdAstraBridgingByMask
// import AdAstraBridgingNSExtensions
#endif


public enum AdAstraColor: CaseIterable {
    public static var CollaboratorColors: [AdAstraColor] = { [
        red,
        orange,
        yellow,
        // sand,
        // navyBlue,
        // black,
        magenta,
        // teal,
        skyBlue,
        green,
        // mint,
        // white,
        // gray,
        // forestGreen,
        purple,
        // brown,
        // plum,
        watermelon,
        lime,
        pink,
        // maroon,
        // coffee,
        // powerBlue,
        // oceanBlue
    ] }()
    
    public static var BorderColors: [AdAstraColor] = { [
        red,
        orange,
        yellow,
        sand,
        navyBlue,
        // black,
        magenta,
        teal,
        skyBlue,
        green,
        mint,
        // white,
        gray,
        forestGreen,
        purple,
        brown,
        plum,
        watermelon,
        lime,
        pink,
        maroon,
        coffee,
        powerBlue,
        oceanBlue
    ] }()
    
    case red, orange, yellow, sand, navyBlue, black, magenta, teal, skyBlue, green, mint, white, gray, forestGreen, purple, brown, plum, watermelon, lime, pink, maroon, coffee, powerBlue, oceanBlue
    
    
    static let Light: [Color] = [
        Color(red: 0.906, green: 0.298, blue: 0.235, opacity: 1.000),
        Color(red: 0.902, green: 0.494, blue: 0.133, opacity: 1.000),
        Color(red: 1.000, green: 0.804, blue: 0.008, opacity: 1.000),
        Color(red: 0.941, green: 0.871, blue: 0.706, opacity: 1.000),
        Color(red: 0.204, green: 0.286, blue: 0.369, opacity: 1.000),
        Color(red: 0.169, green: 0.169, blue: 0.169, opacity: 1.000),
        Color(red: 0.608, green: 0.349, blue: 0.714, opacity: 1.000),
        Color(red: 0.227, green: 0.435, blue: 0.506, opacity: 1.000),
        Color(red: 0.204, green: 0.596, blue: 0.859, opacity: 1.000),
        Color(red: 0.180, green: 0.800, blue: 0.443, opacity: 1.000),
        Color(red: 0.102, green: 0.737, blue: 0.612, opacity: 1.000),
        Color(red: 0.925, green: 0.941, blue: 0.945, opacity: 1.000),
        Color(red: 0.584, green: 0.647, blue: 0.651, opacity: 1.000),
        Color(red: 0.204, green: 0.373, blue: 0.255, opacity: 1.000),
        Color(red: 0.455, green: 0.369, blue: 0.773, opacity: 1.000),
        Color(red: 0.369, green: 0.271, blue: 0.204, opacity: 1.000),
        Color(red: 0.369, green: 0.204, blue: 0.369, opacity: 1.000),
        Color(red: 0.937, green: 0.443, blue: 0.478, opacity: 1.000),
        Color(red: 0.647, green: 0.776, blue: 0.231, opacity: 1.000),
        Color(red: 0.957, green: 0.486, blue: 0.765, opacity: 1.000),
        Color(red: 0.475, green: 0.188, blue: 0.165, opacity: 1.000),
        Color(red: 0.639, green: 0.525, blue: 0.443, opacity: 1.000),
        Color(red: 0.722, green: 0.788, blue: 0.945, opacity: 1.000),
        Color(red: 0.314, green: 0.396, blue: 0.631, opacity: 1.000)    ]
    
    static let Dark: [Color] = [
        Color(red: 0.753, green: 0.224, blue: 0.169, opacity: 1.000), //
        Color(red: 0.827, green: 0.329, blue: 0.000, opacity: 1.000), //
        Color(red: 1.000, green: 0.659, blue: 0.000, opacity: 1.000), //
        Color(red: 0.835, green: 0.761, blue: 0.584, opacity: 1.000), //
        Color(red: 0.173, green: 0.243, blue: 0.314, opacity: 1.000), //
        Color(red: 0.149, green: 0.149, blue: 0.149, opacity: 1.000), //
        Color(red: 0.557, green: 0.267, blue: 0.678, opacity: 1.000), //
        Color(red: 0.208, green: 0.384, blue: 0.447, opacity: 1.000), //
        Color(red: 0.161, green: 0.502, blue: 0.725, opacity: 1.000), //
        Color(red: 0.153, green: 0.682, blue: 0.376, opacity: 1.000), //
        Color(red: 0.086, green: 0.627, blue: 0.522, opacity: 1.000), //
        Color(red: 0.741, green: 0.765, blue: 0.780, opacity: 1.000), //
        Color(red: 0.498, green: 0.549, blue: 0.553, opacity: 1.000), //
        Color(red: 0.176, green: 0.314, blue: 0.212, opacity: 1.000), //
        Color(red: 0.357, green: 0.282, blue: 0.635, opacity: 1.000), //
        Color(red: 0.314, green: 0.231, blue: 0.173, opacity: 1.000), //
        Color(red: 0.310, green: 0.169, blue: 0.310, opacity: 1.000), //
        Color(red: 0.851, green: 0.329, blue: 0.349, opacity: 1.000), //
        Color(red: 0.557, green: 0.690, blue: 0.129, opacity: 1.000), //
        Color(red: 0.831, green: 0.361, blue: 0.620, opacity: 1.000), //
        Color(red: 0.400, green: 0.149, blue: 0.129, opacity: 1.000), //
        Color(red: 0.557, green: 0.447, blue: 0.369, opacity: 1.000), //
        Color(red: 0.600, green: 0.671, blue: 0.835, opacity: 1.000), //
        Color(red: 0.224, green: 0.298, blue: 0.506, opacity: 1.000), //
    ]
    
    public var light: Color {
        let index = Self.allCases.firstIndex(of: self)
        return Self.Light[safeIndex: index] ?? Color.clear
    }
    public var dark: Color {
        let index = Self.allCases.firstIndex(of: self)
        return Self.Dark[safeIndex: index] ?? Color.clear
    }
    public var system: Color {
        if Color.isLightMode {
            return self.light
        }
        if Color.isDarkMode{
            return self.dark
			
        }
        return Color.clear
    }
    
}

#if os(iOS)
public extension UIColor {
    convenience init(adAstraColor value: AdAstraColor){
        self.init(value.system)
    }
}
#elseif os(macOS)
public extension NSColor {
    convenience init(adAstraColor value: AdAstraColor){
        self.init(value.system)
    }
}
#endif

