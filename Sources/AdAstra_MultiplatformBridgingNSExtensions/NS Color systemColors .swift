//
//  File.swift
//  File
//
//  Created by CMS on 12/9/21.
//

import Foundation

#if os(macOS)
import AppKit
import AdAstraBridgingByShim

public extension NSColor {
//  static var label: NSColor { self.labelColor }
  
    static var aaSystemGray2: NSColor {
      NSColor.isLightMode ?
            NSColor(red: 174/255, green: 174/255, blue: 178/255, alpha: 1.0) :
            NSColor(red: 99/255, green: 99/255, blue: 102/255, alpha: 1.0)
        

    }

    static var aaSystemGray3: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0) :
            NSColor(red: 72/255, green: 72/255, blue: 74/255, alpha: 1.0)
        }
    }

    static var aaSystemGray4: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1.0) :
            NSColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1.0)
        }
    }

    static var aaSystemGray5: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0) :
            NSColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0)
        }
    }

    static var aaSystemGray6: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) :
            NSColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        }
    }

    static var aaQuaternaryLabel: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.2) :
            NSColor(red: 235/255, green: 235/255, blue: 246/255, alpha: 0.2)
        }
    }

    static var aaQuaternarySystemFill: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.2) :
            NSColor(red: 235/255, green: 235/255, blue: 246/255, alpha: 0.2)
        }
    }



    static var aaSeparator: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3) :
            NSColor(red: 84/255, green: 84/255, blue: 88/255, alpha: 0.3)
        }
    }
    
    static var aaOpaqueSeparator: NSColor {
        NSColor(name: nil){ (traits) -> NSColor in
            traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
            NSColor(red: 198/255, green: 198/255, blue: 200/255, alpha: 1.0) :
            NSColor(red: 56/255, green: 56/255, blue: 58/255, alpha: 1.0)
        }
    }





	static var aaSecondarySystemFill: NSColor {
		NSColor(name: nil){ (traits) -> NSColor in
			traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
			NSColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16) :
			NSColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.32)
		}
	}

	static var aaTertiarySystemFill: NSColor {
		NSColor(name: nil){ (traits) -> NSColor in
			traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
			NSColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12) :
			NSColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.24)
		}
	}

	static var aaTertiarySystemBackground: NSColor {
		NSColor(name: nil){ (traits) -> NSColor in
			traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
			NSColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0) :
			NSColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0)
		}
	}

	static var aaSecondarySystemGroupedBackground: NSColor {
		NSColor(name: nil){ (traits) -> NSColor in
			traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
			NSColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0) :
			NSColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
		}
	}

	static var aaTertiarySystemGroupedBackground: NSColor {
		NSColor(name: nil){ (traits) -> NSColor in
			traits.bestMatch(from: [.darkAqua, .aqua]) == .aqua ?
			NSColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) :
			NSColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0)
		}
	}

// https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
}
#endif

