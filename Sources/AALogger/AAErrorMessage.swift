import SwiftUI
import AALogger
import os.log

public struct AAErrorMessage: Error {
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

  public let devMessage: String
  public let userMessage: String?
}

