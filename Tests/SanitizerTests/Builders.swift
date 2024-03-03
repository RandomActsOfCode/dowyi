import Foundation
import Model

/// Top level entry for tests for creating a Package and PackageImport
/// from the minimally provided description
/// - Parameters:
///   - sourceImport: The SourceImport driving the test
///   - dependencies: The dependencies associated with the SourceImport
/// - Returns: A configured Package and PackageImport suitable for testing a sanitizer
func test(
  from sourceImport: SourceImport,
  dependencies: [String]
) -> (Package, PackageImport) {
  test(from: [sourceImport], dependencies: dependencies)
}

/// Top level entry for tests for creating a Package and PackageImport
/// from the minimally provided description
/// - Parameters:
///   - sourceImports: The SourceImport instances driving the test
///   - dependencies: The dependencies associated with the SourceImport
/// - Returns: A configured Package and PackageImport suitable for testing a sanitizer
func test(
  from sourceImports: [SourceImport],
  dependencies: [String]
) -> (Package, PackageImport) {
  let packageImport: PackageImport = .test(from: sourceImports)
  let package: Package = .test(from: packageImport, dependencies: dependencies)
  return (package, packageImport)
}

extension Package {
  /// Generate a Package from a PackageImport suitable for testing a sanitizer
  /// - Parameters:
  ///   - imports: The PackageImport to create the Package from
  ///   - dependencies: Dependencies to use
  /// - Returns: A Package configured based on the input
  static func test(from imports: PackageImport, dependencies: [String]) -> Self {
    .init(
      name: "Fake",
      targets: imports.targetImports.map {
        .init(
          name: $0.targetName,
          type: .regular,
          dependencies: dependencies.map { .local(.init(name: $0)) }
        )
      }
    )
  }
}

extension PackageImport {
  /// Generate a PackageImport from a SourceImport suitable for testing a sanitizer
  /// - Parameter sourceImport: The SourceImport to drive generation from
  /// - Returns: A PackageImport derived from the SourceImport
  static func test(from sourceImport: SourceImport) -> Self {
    .init(
      targetImports: [
        .init(targetName: "Test", type: .regular, sourceImports: [sourceImport]),
      ]
    )
  }

  /// Generate a PackageImport from a multiple SourceImport instance suitable for
  /// testing a sanitizer
  /// - Parameter sourceImports: The SourceImport instance to drive generation from
  /// - Returns: A PackageImport derived from the SourceImport
  static func test(from sourceImports: [SourceImport]) -> Self {
    .init(
      targetImports: [
        .init(targetName: "Test", type: .regular, sourceImports: sourceImports),
      ]
    )
  }
}

extension SourceImport {
  /// Generate a SourceImport from a module name
  /// - Parameter module: The name of the module being imported
  /// - Returns: A SourceImport derived from the module name suitable for testing
  static func test(using module: String) -> Self {
    .init(
      file: URL(fileURLWithPath: "Test.swift"),
      lineNumber: 1,
      rawText: "import \(module)",
      module: module
    )
  }
}

extension Array where Element == SourceImport {
  /// Generate SourceImport instances from a module names
  /// - Parameter modules: The names of the modules being imported
  /// - Returns: SourceImport instances derived from the module names suitable for testing
  static func test(using modules: [String]) -> Self {
    modules.map {
      Element(
        file: URL(fileURLWithPath: "Test.swift"),
        lineNumber: 1,
        rawText: "import \($0)",
        module: $0
      )
    }
  }
}

// MARK: - Configuration.Builder

extension Configuration {
  /// A builder which simplifies creation of Configuration instances
  /// in a testing context
  final class Builder {
    // MARK: Lifecycle

    init() {
      self.config = .fake
    }

    // MARK: Internal

    func build() -> Configuration {
      config
    }

    func withExportedImport(_ exportedImport: ExportedImport) -> Self {
      config.exportedImports.append(exportedImport)
      return self
    }

    // MARK: Private

    private var config: Configuration
  }
}
