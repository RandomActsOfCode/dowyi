import Foundation
import Utility

// MARK: - ConsoleLogger

public struct ConsoleLogger {
  // MARK: Lifecycle

  public init(debugLoggingEnabled: Bool = false) {
    self.debugLoggingEnabled = debugLoggingEnabled
  }

  // MARK: Public

  public static var shared = Self()

  public var debugLoggingEnabled: Bool = false
}

// MARK: ConsoleLogger.LogLevel

extension ConsoleLogger {
  public enum LogLevel {
    case debug
    case warning
    case info
    case status
    case error
  }
}

// MARK: ConsoleLogger.AnsiColor

extension ConsoleLogger {
  public func log(_ level: LogLevel, _ message: String) {
    let prefix: String
    let color: String
    let reset = AnsiColor.reset.colorCode

    switch level {
    case .debug:
      guard debugLoggingEnabled else { return }
      prefix = "DEBUG: "
      color = ""

    case .warning:
      prefix = "WARNING: "
      color = AnsiColor.yellow.colorCode

    case .info:
      prefix = ""
      color = AnsiColor.white.colorCode

    case .status:
      prefix = ""
      color = AnsiColor.green.colorCode

    case .error:
      prefix = "ERROR: "
      color = AnsiColor.red.colorCode
    }

    let output = "\(color)\(prefix)\(message)\(reset)"
    print(output)
  }
}
