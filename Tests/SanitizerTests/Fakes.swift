import Foundation
import struct Model.Configuration
import Sanitizer

extension Logger {
  /// A logger that does nothing
  static var noop: Self = .init(
    log: { _, _ in }
  )
}

extension Configuration {
  /// An empty configuration
  static var fake: Self {
    .init(
      swiftExecPath: URL(fileURLWithPath: "not a path"),
      systemFrameworks: [],
      exportedImports: [],
      ignoredFrameworks: [],
      ignoredTargets: [],
      enableDebugLogging: false
    )
  }
}
