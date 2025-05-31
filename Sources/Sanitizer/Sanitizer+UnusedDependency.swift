import Foundation
import Model
import Utility

extension Sanitizer {
  /// A sanitizer which finds any dependencies not being used within a given target
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - packageImport: A description of all imports in the Package
  ///   - config: The tool's configuration file
  /// - Returns: A sanitizer which finds any unused target dependencies
  static func unusedDependency(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> Sanitizer {
    .init {
      findUnusedDependencies(
        package: package,
        packageImport: packageImport,
        config: config,
        logger: logger
      )
    }
  }

  fileprivate static func findUnusedDependencies(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> [ValidationError] {
    var errors: [ValidationError] = []
    let targetImports = packageImport.targetImports
    let targets = Sanitizer.filterTargets(package, config, logger)

    for target in targets {
      let debugHeader = AnsiColor.withColor(
        .yellow,
        "Unused Dependencies: processing target: \(target.name)"
      )
      logger.log(.debug, debugHeader)

      var importedDependencies: Set<TargetDependency> = []

      let targetImport = targetImports.first { $0.targetName == target.name }
      guard let targetImport else {
        continue
      }

      let sourceImports = Sanitizer.filterSourceImport(
        targetImport.sourceImports,
        config,
        logger
      )

      for sourceImport in sourceImports {
        let dependency = target.dependencies.first { $0.name == sourceImport.module }
        guard let dependency else { continue }
        importedDependencies.insert(dependency)
      }

      let allDependencies = Set(target.dependencies)
      let unusedDependencies = allDependencies.subtracting(importedDependencies)

      errors += unusedDependencies.map {
        .unusedDependency(
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
