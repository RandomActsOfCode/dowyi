import Foundation

// MARK: - Logger

/// A logger used for diagnostics
public struct Logger {
  // MARK: Lifecycle

  /// Create an instance of Logger
  /// - Parameter log: An endpoint for logging messages
  public init(
    log: @escaping (Level, String) -> ()
  ) {
    self.log = log
  }

  // MARK: Public

  /// An endpoint for listing directory contents
  public var log: (Level, String) -> ()
}

// MARK: Logger.Level

extension Logger {
  /// A log level for logging messages
  public enum Level {
    /// A warning displayed to the user
    case warning

    /// A debug message display to the user
    case debug
  }
}
