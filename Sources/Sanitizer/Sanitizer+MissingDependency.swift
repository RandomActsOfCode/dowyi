import Foundation
import Model
import Utility

extension Sanitizer {
  /// A sanitizer which finds any dependencies missing for corresponding imports within a given target
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - packageImport: A description of all imports in the Package
  ///   - config: The tool's configuration file
  /// - Returns: A sanitizer which finds any missing target dependencies
  static func missingDependencySanitizer(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> Sanitizer {
    .init {
      findMissingDependencies(
        package: package,
        packageImport: packageImport,
        config: config,
        logger: logger
      )
    }
  }

  fileprivate static func findMissingDependencies(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> [ValidationError] {
    var errors: [ValidationError] = []
    let targetImports = packageImport.targetImports

    for target in Sanitizer.filterTargets(package, config, logger) {
      let debugHeader = AnsiColor.withColor(
        .yellow,
        "Missing Dependencies: processing target: \(target.name)"
      )
      logger.log(.debug, debugHeader)

      let targetImport = targetImports.first { $0.targetName == target.name }
      guard let targetImport else {
        logger.log(.debug, "Skipping target - no imports found")
        continue
      }

      let sourceImports = Sanitizer.filterSourceImport(
        targetImport.sourceImports,
        config,
        logger
      )

      for sourceImport in sourceImports {
        let dependency = target.dependencies.first { $0.name == sourceImport.module }

        guard dependency == nil else {
          let message = "Found dependency for import of \(sourceImport.module)"
          logger.log(.debug, message)
          continue
        }

        let message = "No dependency found for \(sourceImport.module)"
        logger.log(.debug, message)

        let exportedImport = config.exportedImports.first {
          $0.exportedImports.contains(sourceImport.module)
        }

        let hasExportedDependency = target.dependencies.contains {
          guard let exportedImport else { return false }
          return $0.name == exportedImport.importFramework
        }

        guard !hasExportedDependency else {
          let moduleName = exportedImport?.importFramework ?? "<none>"
          let message = "Found dependency for exported import of \(moduleName)"
          logger.log(.debug, message)
          continue
        }

        errors += [
          .missingDependency(
            detail: .init(
              targetName: target.name,
              sourceImport: sourceImport
            )
          ),
        ]
      }
    }

    return errors
  }
}
