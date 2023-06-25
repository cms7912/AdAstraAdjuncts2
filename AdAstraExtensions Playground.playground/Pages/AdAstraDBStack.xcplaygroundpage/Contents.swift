//: [Previous](@previous)

import Foundation
import AppKit
import PlaygroundSupport

import AdAstra_Extensions2
import AdAstraDBStack

let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
PlaygroundPage.current.liveView = views[0] as! NSView




_ = ProjectsDBStack

//: [Next](@next)
