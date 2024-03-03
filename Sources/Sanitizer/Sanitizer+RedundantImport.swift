import Foundation
import Model
import Utility

extension Sanitizer {
  /// A sanitizer which finds any imports of an exported import which is also imported
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - packageImport: A description of all imports in the Package
  ///   - config: The tool's configuration file
  /// - Returns: A sanitizer which finds any redundant imports
  static func redundantImport(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> Sanitizer {
    .init {
      findRedundantImports(
        package: package,
        packageImport: packageImport,
        config: config,
        logger: logger
      )
    }
  }

  fileprivate static func findRedundantImports(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  ) -> [ValidationError] {
    var errors: [ValidationError] = []
    let targetImports = packageImport.targetImports
    let targets = Sanitizer.filterTargets(package, config, logger)

    for target in targets {
      let debugHeader = AnsiColor.withColor(
        .yellow,
        "Redundant Imports: processing target: \(target.name)"
      )
      logger.log(.debug, debugHeader)

      let targetImport = targetImports.first { $0.targetName == target.name }
      guard let targetImport else {
        logger.log(.debug, "Target has no dependencies, nothing to do!")
        continue
      }

      let sourceImports = Sanitizer.filterSourceImport(
        targetImport.sourceImports,
        config,
        logger
      )

      let fileImports: [URL: [SourceImport]] = .init(
        sourceImports.map { ($0.file, [$0]) },
        uniquingKeysWith: { $0 + $1 }
      )

      for (file, imports) in fileImports {
        let targetErrors = redundantImports(
          targetName: target.name,
          file: file,
          sourceImports: imports,
          config: config
        )

        logger.log(.debug, "Found \(targetErrors.count) errors")

        errors += targetErrors
      }
    }

    return errors
  }

  private static func redundantImports(
    targetName: String,
    file: URL,
    sourceImports: [SourceImport],
    config: Configuration
  ) -> [Sanitizer.ValidationError] {
    guard !config.exportedImports.isEmpty else {
      return []
    }
    var errors: [ValidationError] = []

    for exportedImport in config.exportedImports {
      let isImportingModule = sourceImports.contains {
        $0.module == exportedImport.importFramework
      }

      guard isImportingModule else { continue }

      let exportedImportImports = sourceImports.filter { sourceImport in
        exportedImport.exportedImports.contains { $0 == sourceImport.module }
      }

      errors += exportedImportImports.map {
        .redundantImport(
          detail: .init(
            targetName: targetName,
            sourceImport: $0
          )
        )
      }
    }

    return errors
  }
}
