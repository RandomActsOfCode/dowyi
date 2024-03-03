import Foundation
import Live
import Model

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

extension FileManager {
  /// Create a Model FileSystem from the system FileManager
  static func fileSystem() -> FileSystem {
    .init(
      fileContents: { url in
        try String(contentsOf: url)
          .split(separator: "\n")
          .map(String.init)
      },

      recursiveDirectoryContent: { directory in
        let enumerator = FileManager.default.enumerator(
          at: directory,
          includingPropertiesForKeys: nil
        )

        var files: [URL] = []
        while let object = enumerator?.nextObject() {
          guard let url = object as? URL else { continue }
          files.append(url)
        }

        return files
      }
    )
  }
}
