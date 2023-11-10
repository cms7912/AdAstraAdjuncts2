//
//  KeyCommand.swift
//  Adds Keyboard Shortcuts to SwiftUI on iOS 13
//  See https://steipete.com/posts/fixing-keyboardshortcut-in-swiftui/
//  License: MIT
//
// Usage: (wrap view in `KeyboardEnabledHostingController`)
// Button(action: {
//       print("Button Tapped!!")
//  }) {
//       Text("Button")
//  }
// .keyCommand("e", modifiers: [.control])

import SwiftUI
import Combine

#if os(iOS)

/// Subclass for `UIHostingController` that enables using the `onKeyCommand` extension.
@available(iOS 13.0, *) //, macOS 11.0, *)
class KeyboardEnabledHostingController<Content>: UIHostingController<KeyboardEnabledHostingController.Wrapper> where Content: View {
    private let registrator = KeyCommandRegistrator()

    init(rootView: Content) {
        super.init(rootView: Wrapper(content: rootView, registrator: registrator))
    }

    struct Wrapper: View {
        let content: Content
        fileprivate let registrator: KeyCommandRegistrator

        var body: some View {
            content.environmentObject(registrator)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var keyCommands: [UIKeyCommand]? {
        registrator.keyCommands + (super.keyCommands ?? [])
    }

    // This method must be inside a responder, else it's hidden
    @objc private func performKeyCommand(_ keyCommand: UIKeyCommand) {
        guard let input = keyCommand.input else { return }
        let keyPair = KeyCommandPair(input: input, modifiers: keyCommand.modifierFlags)
        registrator.keyPublisher.send(keyPair)
    }

    override var canBecomeFirstResponder: Bool { true }
}

@available(iOS 13.0, *)
private struct KeyCommandStyle: PrimitiveButtonStyle {
    var commandPair: KeyCommandPair

    // Purely additive style: https://developer.apple.com/documentation/swiftui/button/init(_:)
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .keyCommand(keyPair: commandPair, action: configuration.trigger)
    }
}

@available(iOS 13.0, *)
extension View {
    /// Register a key command for the current button, invoking the button action when triggered.
    func keyCommand(_ key: String, modifiers: UIKeyModifierFlags = .command, cardTitle: String = "") -> some View {
        buttonStyle(KeyCommandStyle(commandPair: KeyCommandPair(input: key, modifiers: modifiers)))
    }

    /// Register a key command for the current view
    public func onKeyCommand(_ key: String, modifiers: UIKeyModifierFlags = .command, cardTitle: String = "", action: @escaping () -> Void) -> some View {
        keyCommand(keyPair: KeyCommandPair(input: key, modifiers: modifiers, cardTitle: cardTitle), action: action)
    }

    fileprivate func keyCommand(keyPair: KeyCommandPair, action: @escaping () -> Void) -> some View {
        self.modifier(KeyCommandModifier(commandPair: keyPair, action: action))
    }
}

@available(iOS 13.0, *)
private struct KeyCommandModifier: ViewModifier {
    @EnvironmentObject var registrator: KeyCommandRegistrator
    fileprivate var commandPair: KeyCommandPair
    var action: () -> Void

    func body(content: Content) -> some View {
        content
            .padding(0) // without a modification, onReceive is not called
            .onReceive(registrator.keyPublisher.filter { $0 == self.commandPair }) { _ in action() }
            .onAppear {
                registrator.register(commandPair)
            }
    }
}

@available(iOS 13.0, *)
private class KeyCommandRegistrator: ObservableObject {
    var keyCommands: [UIKeyCommand] = []
    let keyPublisher = PassthroughSubject<KeyCommandPair, Never>()

    func register(_ commandPair: KeyCommandPair) {
        let command = UIKeyCommand(title: commandPair.cardTitle ?? "",
                                   action: NSSelectorFromString("performKeyCommand:"),
                                   input: commandPair.input,
                                   modifierFlags: commandPair.modifiers)

        keyCommands += [command]
    }
}

@available(iOS 13.0, *)
private struct KeyCommandPair: Equatable {
    var input: String
    var modifiers: UIKeyModifierFlags
    var cardTitle: String?

    static func == (lhs: KeyCommandPair, rhs: KeyCommandPair) -> Bool {
        return lhs.input == rhs.input && lhs.modifiers == rhs.modifiers
    }
}
#endif
