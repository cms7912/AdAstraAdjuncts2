//
//  File.swift
//  
//
//  Created by cms on 12/6/21.
//

import Foundation
#if os(macOS)

// mask for DeviceKit compatibility 
public enum Device {
   public static var current: String { "Mac" }
   public static var identifier: String { "Mac" }
}


import AppKit

//import AdAstraBridgingNSExtensions

public typealias UIView = NSView
public typealias UIColor = NSColor
public typealias UIFont = NSFont
public typealias UIImage = NSImage
public typealias UIImageView = NSImageView
public typealias UITextView = NSTextView
public typealias UIBezierPath = NSBezierPath
public typealias UIScrollView = NSScrollView
// public typealias UIScrollViewDelegate = NSScrollViewDelegate
public typealias UIScreen = NSScreen
public typealias UIWindow = NSWindow
public typealias UINSScene = NSObject // no equivalent
public typealias UIEdgeInsets = NSEdgeInsets
public typealias UITextViewDelegate = NSTextViewDelegate
public typealias UINSSplitViewController = NSSplitViewController
public typealias UINSSplitViewDelegate = NSSplitViewDelegate

// public typealias UIKeyCommand = NSLimitedKeyCommand

public typealias UILayoutPriority = NSLayoutConstraint.Priority

public typealias UIAlertController = NSAlert
//public typealias UIAlertAction = NSAppAlertAction // bridge below for NS UIAlertAction

public typealias UIApplication = NSApplication
public typealias UIApplicationDelegate = NSApplicationDelegate
// public typealias UIBackgroundFetchResult = NSBackgroundFetchResult
public typealias UIViewController = NSViewController

//public typealias UIDocumentPickerDelegate = NSDocumentPickerDelegate


public typealias UICollectionView = NSCollectionView
public typealias UICollectionViewDataSource = NSCollectionViewDataSource
public typealias UICollectionViewCell = NSCollectionViewItem




#endif



//MARK: -- SwiftUI

#if os(macOS) && canImport(SwiftUI)
import SwiftUI

public typealias UIHostingController = NSHostingController
public typealias UIHostingView = NSHostingView
public typealias UIViewControllerRepresentable = NSViewControllerRepresentable
public typealias UIViewControllerRepresentableContext = NSViewControllerRepresentableContext
public typealias UIViewRepresentable = NSViewRepresentable

#endif

