//: [Previous](@previous)

import Foundation
import AppKit
import PlaygroundSupport

import AdAstraExtensions
import AdAstraDBStackCore

let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
PlaygroundPage.current.liveView = views[0] as! NSView




_ = ProjectsDBStack.shared

//: [Next](@next)
