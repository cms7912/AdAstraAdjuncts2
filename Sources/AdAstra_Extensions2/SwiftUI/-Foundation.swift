//
//  File.swift
//
//
//  Created by cms on 2/15/22.
//

import Foundation
import SwiftUI
import Combine
import OSLog

@propertyWrapper
public class PublishedDelta<Value: Equatable> {
  private var val: Value
  private let subject: CurrentValueSubject<Value, Never>

  public init(wrappedValue: Value) {
    val = wrappedValue
    subject = CurrentValueSubject(wrappedValue)
    self.wrappedValue = wrappedValue
  }

  public var wrappedValue: Value {
    set {
      guard val != newValue else { return }
      val = newValue
      subject.send(val)
    }
    get { val }
  }

  // var projectedValue: PassthroughSubject<Value, Never> {
  //   public var projectedValue: Published<Value>.Publisher {
  public var projectedValue: CurrentValueSubject<Value, Never> { subject }
  // https://stackoverflow.com/questions/58403338/is-there-an-alternative-to-combines-published-that-signals-a-value-change-afte
}

public struct AssertEmptyView: View {
  public init() { }
  public var body: some View {
    // assert(false)
    return EmptyView()
  }
}


//
// class PublishedChanges<Value: Equatable> {
// 	private var val: Value
// 	private let subject: Published<Value>.Publisher
//
// 	public init(wrappedValue: Value) {
// 		val = wrappedValue
// 		subject = Published.Publisher(wrappedValue)
// 		self.wrappedValue = wrappedValue
// 	}
// 	public init(initialValue: Value){
// 		init(wrappedValue: initialValue) // ????
// 	}
//
// 	public var wrappedValue: Value {
// 		set {
// 			guard val != newValue else { return }
// 			val = newValue
// 			subject.send(val)
// 		}
// 		get { val }
// 	}
//
// 	public var projectedValue: Published<Value>.Publisher {
// 		get { subject }
// 	}
// 	// https://stackoverflow.com/questions/58403338/is-there-an-alternative-to-combines-published-that-signals-a-value-change-afte
// }



public struct AASquircle: Animatable, InsettableShape, Shape, View {
  public init() { }
  public func inset(by amount: CGFloat) -> some InsettableShape {
    var myself = self
    myself.insetAmount -= amount
    return myself
  }

  var insetAmount: CGFloat = 0



  // https://developer.apple.com/documentation/swiftui/roundedrectangle
  let ratio: CGFloat = 10 / 57
  public func path(in rect: CGRect) -> Path {
    let newRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
    return Path(roundedRect: rect,
                cornerSize: CGSize(w: newRect.width * ratio,
                                   h: newRect.height * ratio),
                style: .continuous)
  }
}

public extension EmptyView {
  static func assertUIFlag(color: Color = .orange, size: CGSize = .square(30)) -> some View {
    #if DEBUG
    Rectangle()
      .fill(color)
      .frame(size)
      .overlay{
        Image(systemName: "flag")
          .foregroundColor(.white)
      }
    #else
    EmptyView()
    #endif
  }
}

