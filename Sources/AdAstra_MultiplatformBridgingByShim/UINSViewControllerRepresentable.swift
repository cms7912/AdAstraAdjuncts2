//
//  File.swift
//  
//
//  Created by cms on 4/4/22.
//

import Foundation
import SwiftUI

// USAGE:
/*
 struct ShareSheet: UINSViewControllerRepresentableCaller {
 typealias ViewControllerType = UINSActivityViewController


 func makeViewController(context: Context) -> ViewControllerType {
 UINSActivityViewController( activityItems: sharePaths, applicationActivities: nil )
 }

 func updateViewController(_ viewController: ViewControllerType, context: Context) {
 }
 }
 class UINSViewControllerRepresentableCoordinator<Content: View>: NSObject {
 var parentRepresentable: ShareSheet.ViewControllerType
 init(_ parentRepresentable: ShareSheet.ViewControllerType) {
 self.parentRepresentable = parentRepresentable
 }
 }

 */

public protocol UINSViewControllerRepresentable: ViewControllerRepresentable {
	associatedtype ViewControllerType

	func makeViewController(context: Context) -> ViewControllerType

	func updateViewController(_ viewController: ViewControllerType, context: Context)

}

#if os(iOS)
public typealias ViewControllerRepresentable = UIViewControllerRepresentable
public extension UINSViewControllerRepresentable {

// UIKIt calls, forwarded to universal calls:
func makeUIViewController(context: Context) -> ViewControllerType {
	makeViewController(context: context) }
func updateUIViewController(_ uiViewController: ViewControllerType, context: Context) {
	updateViewController(uiViewController, context: context) }
}

#elseif os(macOS)
public typealias ViewControllerRepresentable = NSViewControllerRepresentable
public extension UINSViewControllerRepresentable {

// AppKit calls, forwarded to universal calls:
func makeNSViewController(context: Context) -> ViewControllerType {
	makeViewController(context: context)
}
func updateNSViewController(_ nsViewController: ViewControllerType, context: Context) {
	updateViewController(nsViewController, context: context)
}

}
#endif


