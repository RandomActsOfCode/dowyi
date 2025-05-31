import Foundation
import Model

extension Sanitizer {
  /// Filter targets to validate based on the provided configuration
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - config: The configuration file
  /// - Returns: A filtered collection of targets
  static func filterTargets(
    _ package: Package,
    _ config: Configuration,
    _ logger: Logger
  )
    -> [Target] {
    package.targets.filter { target in
      let match = config.ignoredTargets.contains { $0.targetName == target.name }

      guard !match else {
        logger.log(.debug, "Skipping target \(target.name) - explicitly ignored")
        return false
      }

      return true
    }
  }

  /// Filter source imports to validate based on the provided configuration
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - config: The configuration file
  /// - Returns: A filtered collection of source imports
  static func filterSourceImport(
    _ sourceImports: [SourceImport],
    _ config: Configuration,
    _ logger: Logger
  )
    -> [SourceImport] {
    sourceImports.filter {
      guard !config.isSystem($0.module) else {
        logger.log(.debug, "Skipping import of \($0.module) - system module")
        return false
      }

      guard !config.isIgnored($0.module) else {
        logger.log(.debug, "Skipping import of \($0.module) - explicitly ignored")
        return false
      }

      return true
    }
  }
}
