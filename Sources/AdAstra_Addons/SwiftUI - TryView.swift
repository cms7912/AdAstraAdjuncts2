import SwiftUI
import OSLog
import AALogger

public struct TryViewCatchKey: PreferenceKey {
  public enum TryViewError {
    case reason(String)
  }

  public static var defaultValue: [Error] = .empty

  public static func reduce(value: inout [Error], nextValue: () -> [Error]) {
    let addingValue = nextValue()
    let updatedValue = value + addingValue
    value = updatedValue
  }
}


public protocol TryViewOnError: View {
  var errorMessage: AAErrorMessage { get }
}
extension AAErrorMessage: TryViewOnError {
  struct ErrorView: View {
    @State var userMessage: String
    public var body: some View {
      Text(userMessage)
        .foregroundColor(Color.white)
        .background{ AdAstraColor.yellow.dark }
    }
  }
  
  public var body: some View {
    LLog(devMessage)
    return VStack{
      Self.ErrorView(userMessage: userMessage ?? "Default Error")
      #if DEBUG
      Text(devMessage)
      #endif
    }
  }

}

// extension String: TryViewOnError {
extension String: TryViewOnError {
  // public var message: String { self }
  public var errorMessage: AAErrorMessage {
    AAErrorMessage(self, self)
  }

  public var body: some View {
    errorMessage
  }
}

// extension View: TryViewOnError { }

public struct TryView<ContentView: View, OnErrorView: TryViewOnError>: View {
  // public struct TryView<ContentView: View>: View {
  public typealias ContentClosure = () throws -> ContentView
  var content: ContentClosure
  // var content: Content
  var onCatchError: (AAErrorMessage) -> OnErrorView
  public init(
    _ content: @escaping ContentClosure,
    // onCatchError: @escaping (AAErrorMessage) -> OnErrorView = {"error: \($0)"}
    onCatchError: @escaping (AAErrorMessage) -> OnErrorView = {AAErrorMessage(nil, "init error: \($0)")}
  ) {
    self.content = content
    self.onCatchError = onCatchError
  }

  public var body: some View {
    Group{
      if unpackCombinedContent().value.0 {
        unpackCombinedContent().value.1
      } else {
        unpackCombinedContent().value.2
      }
    }
  }

  // func unpackCombinedContent() -> TupleView<(ContentView, OnErrorView)> {
  func unpackCombinedContent() -> TupleView<(Bool, ContentView?, AAErrorMessage)> {
    // TupleView(content(), onError())

    var errorMessage = AAErrorMessage(nil, "Default TryView Error Message")

    var contentUnwrapped: ContentView?
    do {
      contentUnwrapped = try content()
      return TupleView((true, contentUnwrapped!, errorMessage))
    } catch let error as AAErrorMessage {
      errorMessage = error
    } catch {
      errorMessage = AAErrorMessage(nil, error.localizedDescription)
    }

    return TupleView((false, contentUnwrapped, errorMessage))
  }



  @ViewBuilder
  func unpackContentView() -> some View {
    if let content = try? content() {
      content
    } else {
      unpackErrorView()
    }
  }

  func unpackErrorView() -> AAErrorMessage? {
    do {
      _ = try content()
    } catch let error as AAErrorMessage {
      return error
    } catch {
      return AAErrorMessage(nil, error.localizedDescription)
    }
    return nil
  }
}

public struct TestView: View {
  public var body: some View {
    TryView{
      EmptyView()
        .frame(h: try testTry())
    }
  }

  func testTry() throws -> CGFloat {
    return 5.0
  }
}
