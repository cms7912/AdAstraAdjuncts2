//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation

// public extension ExpressibleByStringLiteral {
//   static var empty: Self = ""
// }

public extension String {
    func titleCasetoWordsWithSpaces() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase

        // https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words-in-swift
    }
  static var empty: Self { Self.init() }
}

public extension StringProtocol where Self: RangeReplaceableCollection {
    var removingAllNewLines: Self {
        filter(\.isNewline.negated)
    }
    mutating func removeAllNewLines() {
        removeAll(where: \.isNewline)
    }
    // adapted from:  https://stackoverflow.com/questions/34940044/how-to-remove-all-the-spaces-and-n-r-in-a-string/34940183

    var isOnlyWhitespaceOrEmpty: Bool {
        if self.isEmpty { return true }
        if self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        return false
    }

   var asNilIfEmpty: Self? {
      if self.isEmpty { return nil }
      if self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
      return self
   }
}

public extension Optional where Wrapped == String {
	var isOnlyWhitespaceOrEmptyOrNil: Bool {
		if isEmptyOrNil { return true }
		if self!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
		return false
	}
	var asEmptyIfNil: String {
		guard let unwrapped = self else {
			return ""
		}
		return unwrapped
	}

	/// assumes empty should be saved as nil
	var emptyIfNilEditable: String {
		get { asEmptyIfNil }
		set {
			if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				self = nil
			} else {
				self = newValue
			}
		}
	}
}

public extension String {
  func sanitized() -> String {
    // see for ressoning on charachrer sets https://superuser.com/a/358861
    let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
      .union(.newlines)
      .union(.illegalCharacters)
      .union(.controlCharacters)
    
    return self
      .components(separatedBy: invalidCharacters)
      .joined(separator: "")
  }
  
  mutating func sanitizedForFileSystems() -> Void {
    self = self.sanitized().whitespaceCondensed()
  }
  func sanitizeForFileSystems() -> String {
    return self.sanitized().whitespaceCondensed()
  }

  func whitespaceCondensed() -> String {
    return self.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: " ")
  }
  
  mutating func condenseWhitespace() -> Void {
    self = self.whitespaceCondensed()
  }
  
  //var str = "2018/12/06 12:28 \\ - Ourdoor Run: Making a habbit.fgworkout"
  //str.sanitized().whitespaceCondenced() // "20181206 1228 - Ourdoor Run Making a habbit.fgworkout"
// https://gist.github.com/totocaster/3a1f008c780793b86a6c4d2d6ae735c4
}


public extension NSAttributedString {
  var fullRange: NSRange {
    NSRange(location: 0, length: self.length)
  }
  class var empty: Self { Self.init() }
  var mutableAttributedString: NSMutableAttributedString {
    NSMutableAttributedString(attributedString: self)
  }
	static var AssertEmpty: Self {
		assert(false)
		return Self()
	}
  // concatenate attributed strings
  static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
    // https://stackoverflow.com/questions/18518222/how-can-i-concatenate-nsattributedstrings
  }
  
}

public extension AttributedString{
  var fullRange: Range<Index> {
    Range(uncheckedBounds: (startIndex, endIndex))
  }
  var asString: String {
    String(self.characters)
  }

  static var empty: Self { Self.init() }

	static var AssertEmpty: Self {
		assert(false)
		return Self()
	}

}
public extension Optional where Wrapped == AttributedString {
	var asEmptyIfNil: AttributedString {
		guard let unwrapped = self else {
			return AttributedString(stringLiteral: "")
		}
		return unwrapped
	}

	/// assumes empty should be saved as nil
	var emptyIfNilEditable: AttributedString {
		get { asEmptyIfNil }
		set {
			if newValue.characters.isEmpty {
				self = nil
			} else {
				self = newValue
			}
		}
	}
}

public extension AttributedString.CharacterView {
  var asString: String {
    String(self)
  }
}

public extension String {
  static var Assert: String {
    assert(false)
    return ""
  }
}


extension String {
  
  public static func makeUniqueName(name: String, validating: ((String)->Bool)) -> String {
    var candidate = name
    let numberRange: Range<String.Index>? = name.range(of: "[0-9]+$", options: [.regularExpression])
    var number: Int = numberRange.flatMap { Int(name[$0]) } ?? 2
    while !validating(candidate) {
      defer { number += 1 }
      candidate = numberRange.map { name.replacingCharacters(in: $0, with: String(number + 1)) } ?? (name + " " + String(number))
    }
    return candidate
    // https://gist.github.com/codelynx/df0c31ef35de14a9d6ac6d41d565fa02
  }
  
}


public extension String {
	// https://gist.github.com/reitzig/67b41e75176ddfd432cb09392a270218

	static let BadChars = CharacterSet.alphanumerics.inverted

	var uppercasingFirst: String {
		return prefix(1).uppercased() + dropFirst()
	}

	var lowercasingFirst: String {
		return prefix(1).lowercased() + dropFirst()
	}

	var camelized: String {
		guard !isEmpty else {
			return ""
		}

		let parts = self.components(separatedBy: Self.BadChars)

		let first = String(describing: parts.first!).lowercasingFirst
		let rest = parts.dropFirst().map({String($0).uppercasingFirst})

		return ([first] + rest).joined(separator: "")
	}
}

public extension String {
  var snakeCased: String {
    self.components(separatedBy: .whitespacesAndNewlines).joined(separator: "_")

  }
}

