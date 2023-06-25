

public extension Sequence {
  static var empty: [Element] { [Element]() }
  // static var empty: [Self.Element] {  Sequence<Element>  }
}

public extension Collection {
  static var empty: [Element] { [Element]() }
  var isNotEmpty: Bool { !isEmpty }

  // var asEmpty: [Self.Element] { Self.empty }
}

// extension Array: DebugDescription{
public extension Array where Element == DebugDescription {
  var dd: String {
    map{$0.dd}.joined(separator: ", ")
  }
}

public extension Array {
  var isNotEmpty: Bool { !isEmpty }
  subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
    guard index >= 0, index < endIndex else {
      return defaultValue()
    }
    return self[index]
  }

  subscript(safeIndex index: Int?) -> Element? {
    guard let index = index else { return nil }

    guard index >= 0, index < endIndex else {
      return nil
    }
    return self[index]
  }
  // https://www.hackingwithswift.com/example-code/language/how-to-make-array-access-safer-using-a-custom-subscript
}


public extension Array where Element == Any? {
  subscript(safeIndex index: Int) -> Element? {
    get {
      guard index >= 0, index < endIndex else {
        return nil
      }

      return self[index]
    }
    set {
      guard index >= 0, index <= Int.max else { return }

      if index >= 0, index < endIndex {
        self[index] = newValue ?? nil

      } else if index == endIndex {
        append(newValue ?? nil)

      } else {
        // add 'nil' elements to array until newValue can be inserted
        while endIndex < index {
          append(nil)
        }
        append(newValue ?? nil)
      }
    }
  }
}


/*
 extension Dictionary where Key: Hashable {
     subscript<Index: Key>(safeKey: Key) -> Value? {
         get {
             guard let idx = self.index(forKey: safeKey) else { return nil }
             return self[idx]
         }

         set {
             self.updateValue(newValue, forKey: safeKey)
         }
     }
 }
 */

public extension Dictionary {
  static var empty: [Key: Value] { [:]
  }

  static var AssertEmpty: [Key: Value] { assertionFailure(); return .empty }
}

public extension Array {
  /// when index is greater than array's count, then wrap to repeat array until returning element indexed
  subscript(wrapAroundForIndex index: Int?) -> Element? {
    guard var index = index,
          count > 0 else { return nil }
    index += 1

    // let result = index.quotientAndRemainder(dividingBy: (count-1) )
    let result = index.quotientAndRemainder(dividingBy: (count))
    let setIndex = result.remainder

    return self[safeIndex: setIndex - 1]
  }
}

public extension Sequence where Iterator.Element: Hashable {
  func unique() -> [Iterator.Element] {
    var seen: Set<Iterator.Element> = []
    return filter { seen.insert($0).inserted }
  }
  // https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
}

public extension Array where Element: Equatable {
  func itemBefore(_ item: Element?) -> Element? {
    guard let item = item else { return nil }
    let itemIndex = firstIndex{ $0 == item }
    guard let itemIndex = itemIndex else { return nil }
    let newIndex = index(before: itemIndex)
    return self[safeIndex: newIndex]
  }

  func itemAfter(_ item: Element?) -> Element? {
    guard let item = item else { return nil }
    let itemIndex = firstIndex{ $0 == item }
    guard let itemIndex = itemIndex else { return nil }
    let newIndex = index(after: itemIndex)
    return self[safeIndex: newIndex]
  }
}
