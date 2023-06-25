//
//  File.swift
//  
//
//  Created by cms on 8/10/22.
//

import Foundation
import SwiftUI

public protocol UINSViewRepresentable: ViewRepresentable {
  associatedtype ViewType
  
  func makeView(context: Context) -> ViewType
  
  func updateView(_ View: ViewType, context: Context)
  
}

#if os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
public extension UINSViewRepresentable {
  
  // UIKIt calls, forwarded to universal calls:
  func makeUIView(context: Context) -> ViewType {
    makeView(context: context) }
  func updateUIView(_ uiView: ViewType, context: Context) {
    updateView(uiView, context: context) }
}

#elseif os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
public extension UINSViewRepresentable {
  
  // AppKit calls, forwarded to universal calls:
  func makeNSView(context: Context) -> ViewType {
    makeView(context: context)
  }
  func updateNSView(_ nsView: ViewType, context: Context) {
    updateView(nsView, context: context)
  }
  
}
#endif
