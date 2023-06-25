public struct AAErrorMessage: Error, TryViewOnError {
  public static var UnexpectedNil: Self = AAErrorMessage("Internal expected value is missing", "General 'UnexpectedNil' error")
  public static var UnexpectedSwitchDefault: Self = AAErrorMessage("Internal expected value is missing", "General 'UnexpectedSwitchDefault' error")
  public static var UnexpectedDevPath: Self = AAErrorMessage("Internal execution stumbled.", "General 'UnexpectedDevPath' error")

  public var errorMessage: Self { self }
  public init(_ userMessage: String? = nil, _ devMessage: String? = nil,
              filepath: String = #file,
              function: String = #function,
              line _: Int = #line)
  {
    self.devMessage = devMessage.isZeroLengthIfNil + " | " + Logger.ExtractFilename(from: filepath) + " | " + Logger.ExtractMethodName(from: function)
    self.userMessage = userMessage
  }

  let devMessage: String
  let userMessage: String?
  public var body: some View {
    LLog(devMessage)
    return VStack{
      Self.ErrorView(userMessage: userMessage ?? "Default Error")
      #if DEBUG
      Text(devMessage)
      #endif
    }
  }

  struct ErrorView: View {
    @State var userMessage: String
    public var body: some View {
      Text(userMessage)
        .foregroundColor(Color.white)
        .background{ AdAstraColor.yellow.dark }
    }
  }
}

