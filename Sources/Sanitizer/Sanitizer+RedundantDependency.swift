import Foundation
import Model
import Utility

extension Sanitizer {
  /// A sanitizer which finds any direct dependency to an exported import module
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - packageImport: A description of all imports in the Package
  ///   - config: The tool's configuration file
  /// - Returns: A sanitizer which finds any redundant dependencies
  static func redundantDependency(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> Sanitizer {
    .init {
      findRedundantDependencies(
        package: package,
        packageImport: packageImport,
        config: config,
        logger: logger
      )
    }
  }

  fileprivate static func findRedundantDependencies(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  ) -> [ValidationError] {
    var errors: [ValidationError] = []
    let targets = Sanitizer.filterTargets(package, config, logger)

    for target in targets {
      let debugHeader = AnsiColor.withColor(
        .yellow,
        "Redundant Dependencies: processing target: \(target.name)"
      )
      logger.log(.debug, debugHeader)

      guard !target.dependencies.isEmpty else {
        logger.log(.debug, "Target has no dependencies, nothing to do!")
        continue
      }

      let exportedImports = config.exportedImports.filter {
        $0.importFramework != target.name
      }

      let exportedImportDependencies = target.dependencies.filter { dependency in
        exportedImports.contains { exportedImport in
          exportedImport.exportedImports.contains(dependency.name)
        }
      }

      logger.log(.debug, "Found \(exportedImportDependencies.count) errors")

      errors += exportedImportDependencies.map {
        .redundantDependency(
          detail: .init(
            targetName: target.name,
            dependency: $0
          )
        )
      }
    }

    return errors
  }
}
