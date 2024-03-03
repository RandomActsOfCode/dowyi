import Foundation
import Live
import Sanitizer

extension ConsoleLogger {
  /// Create a Model Logger from a ConsoleLogger
  static func logger() -> Logger {
    .init(
      log: { level, message in
        ConsoleLogger.shared.log(.init(level), message)
      }
    )
  }
}

extension ConsoleLogger.LogLevel {
  /// Create a Model LogLevel from a ConsoleLogger.LogLevel
  init(_ level: Logger.Level) {
    switch level {
    case .debug:
      self = .debug

    case .warning:
      self = .warning
    }
  }
}
