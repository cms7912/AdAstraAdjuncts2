
/// A property wrapper for properties of a type that should be "skipped" when the type is encoded or decoded.
@propertyWrapper
public struct SkipCoding<Value: Any> {
  private var value: Value!
  public init(wrappedValue: Value) {
    value = wrappedValue
  }

  public var wrappedValue: Value {
    get { return value }
    set { value = newValue }
  }
}

extension SkipCoding: Codable {
  public func encode(to _: Encoder) throws {
    // Skip encoding the wrapped value.
  }

  public init(from _: Decoder) throws {
    // The wrapped value is simply initialised to nil when decoded.
    value = nil
  }
  // from: https://medium.com/codex/lets-make-a-swift-property-wrapper-that-ignores-variables-when-en-decoding-7a2e270519eb
}

@propertyWrapper
public struct SkipCodingAndWeak<Value: AnyObject> {
  private weak var value: Value?
  public init(wrappedValue: Value? = nil) {
    value = wrappedValue
  }

  public var wrappedValue: Value? {
    get { return value }
    set { value = newValue }
  }
}

extension SkipCodingAndWeak: Codable {
  public func encode(to _: Encoder) throws {
    // Skip encoding the wrapped value.
  }

  public init(from _: Decoder) throws {
    // The wrapped value is simply initialised to nil when decoded.
    value = nil
  }
  // from: https://medium.com/codex/lets-make-a-swift-property-wrapper-that-ignores-variables-when-en-decoding-7a2e270519eb
}

// public protocol SkipCodingWithDefaultValue {
//   associatedtype Value: SkipCodingWithDefaultValue
//   static var DefaultValue: ()->Value { get }
// }
//
// @propertyWrapper
// public struct SkipCodingWithDefault<Value: SkipCodingWithDefaultValue> {
//   private var value: Value = Value.DefaultValue
//   public init(wrappedValue: Value = Value.self.DefaultValue) {
//     self.value = wrappedValue
//   }
//   public var wrappedValue: Value? {
//     get { return value }
//     set { self.value = newValue ?? Value.DefaultValue }
//   }
// }
// extension SkipCodingWithDefault: Codable {
//   public func encode(to encoder: Encoder) throws {
//     // Skip encoding the wrapped value.
//   }
//   public init(defaultValue: Value) {
//     self.value = defaultValue
//   }
//   public init(from decoder: Decoder) throws {
//     // The wrapped value is simply initialized to nil when decoded.
//     self.value = Value.DefaultValue as Value
//   }
//   // from: https://medium.com/codex/lets-make-a-swift-property-wrapper-that-ignores-variables-when-en-decoding-7a2e270519eb
// }
