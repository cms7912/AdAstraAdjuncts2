//
//  Bundle Module fix.swift
//  Mathematica
//
//  Created by Clint Ramirez Stephens  on 8/18/23.
//

#if Disabled20230818
// https://www.appsloveworld.com/swift/100/28/swift-package-manager-type-bundle-has-no-member-module-error


import class Foundation.Bundle

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var module: Bundle = {
        let bundleName = "AdAstraAdjuncts2_AdAstraDBStackUI" // found name
      // /Mathematica.app/AdAstraAdjuncts2_AdAstraDBStackUI.bundle

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: ProjectsDBStack.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named BioSwift_BioSwift")
    }()
}

#endif 
