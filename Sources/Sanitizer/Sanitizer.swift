import Foundation
import Model

// MARK: - Sanitizer

/// An generic import sanitizer
public struct Sanitizer {
  public var sanitize: () -> [ValidationError]
}

extension Sanitizer {
  /// A error produced by a `Sanitizer`
  public enum ValidationError {
    /// A required dependency is missing from the target
    case missingDependency(detail: MissingDependencyDetail)

    /// A target dependency is not used within the sources
    case unusedDependency(detail: UnusedDependencyDetail)

    /// An redundant import of an exported import
    case redundantImport(detail: RedundantImportDetail)

    /// An redundant dependency to an exported import
    case redundantDependency(detail: RedundantDependencyDetail)
  }

  /// A description of a missing dependency error
  public struct MissingDependencyDetail {
    // MARK: Lifecycle

    public init(
      targetName: String,
      sourceImport: SourceImport
    ) {
      self.targetName = targetName
      self.sourceImport = sourceImport
    }

    // MARK: Public

    /// The offending target name
    public var targetName: String

    /// A description of the offending import
    public var sourceImport: SourceImport
  }

  public struct UnusedDependencyDetail {
    // MARK: Lifecycle

    public init(
      targetName: String,
      dependency: TargetDependency
    ) {
      self.targetName = targetName
      self.dependency = dependency
    }

    // MARK: Public

    /// The offending target name
    public var targetName: String

    /// A description of the used dependency
    public var dependency: TargetDependency
  }

  /// A description of a redundant import
  public struct RedundantImportDetail {
    // MARK: Lifecycle

    public init(
      targetName: String,
      sourceImport: SourceImport
    ) {
      self.targetName = targetName
      self.sourceImport = sourceImport
    }

    // MARK: Public

    /// The offending target name
    public var targetName: String

    /// A description of the offending import
    public var sourceImport: SourceImport
  }

  /// A description of a redundant dependency
  public struct RedundantDependencyDetail {
    // MARK: Lifecycle

    public init(
      targetName: String,
      dependency: TargetDependency
    ) {
      self.targetName = targetName
      self.dependency = dependency
    }

    // MARK: Public

    /// The offending target name
    public var targetName: String

    /// A description of the used dependency
    public var dependency: TargetDependency
  }
}

extension Sanitizer.ValidationError {
  public var targetName: String {
    switch self {
    case .missingDependency(let detail):
      detail.targetName

    case .unusedDependency(let detail):
      detail.targetName

    case .redundantImport(let detail):
      detail.targetName

    case .redundantDependency(let detail):
      detail.targetName
    }
  }
}

extension Sanitizer.ValidationError {
  public var typeDescription: String {
    switch self {
    case .missingDependency:
      "Missing Dependency"

    case .unusedDependency:
      "Unused Dependency"

    case .redundantImport:
      "Redundant Import"

    case .redundantDependency:
      "Redundant Dependency"
    }
  }
}

extension Sanitizer.ValidationError {
  public var message: String {
    switch self {
    case .missingDependency(let detail):
      detail.description

    case .unusedDependency(let detail):
      detail.description

    case .redundantImport(let detail):
      detail.description

    case .redundantDependency(let detail):
      detail.description
    }
  }
}

// MARK: - Sanitizer.MissingDependencyDetail + CustomStringConvertible

extension Sanitizer.MissingDependencyDetail: CustomStringConvertible {
  public var description: String {
    """
    File:   \(sourceImport.file.lastPathComponent)
    Line:   \(sourceImport.lineNumber)
    Module: \(sourceImport.module)
    """
  }
}

// MARK: - Sanitizer.UnusedDependencyDetail + CustomStringConvertible

extension Sanitizer.UnusedDependencyDetail: CustomStringConvertible {
  public var description: String {
    """
    Dependency: \(dependency.name)
    Type:       \(dependency.typeName)
    Package:    \(dependency.packageName)
    """
  }
}

// MARK: - Sanitizer.RedundantImportDetail + CustomStringConvertible

extension Sanitizer.RedundantImportDetail: CustomStringConvertible {
  public var description: String {
    """
    File:   \(sourceImport.file.lastPathComponent)
    Line:   \(sourceImport.lineNumber)
    Module: \(sourceImport.module)
    """
  }
}

// MARK: - Sanitizer.RedundantDependencyDetail + CustomStringConvertible

extension Sanitizer.RedundantDependencyDetail: CustomStringConvertible {
  public var description: String {
    """
    Dependency: \(dependency.name)
    Type:       \(dependency.typeName)
    Package:    \(dependency.packageName)
    """
  }
}

extension TargetDependency {
  fileprivate var typeName: String {
    switch self {
    case .external:
      "External"

    case .local:
      "Local"
    }
  }

  fileprivate var packageName: String {
    switch self {
    case .external(let dependency):
      dependency.package

    case .local:
      "--"
    }
  }
}

extension Sanitizer {
  /// A sanitizer which performs all validation checks
  /// - Parameters:
  ///   - package: The simplified Package manifest
  ///   - packageImport: A description of all imports in the Package
  ///   - config: The tool's configuration file
  /// - Returns: A sanitizer which performs all supported validation checks
  public static func allChecks(
    package: Package,
    packageImport: PackageImport,
    config: Configuration,
    logger: Logger
  )
    -> Sanitizer {
    .init {
      Sanitizer.missingDependencySanitizer(
        package: package,
        packageImport: packageImport,
        config: config,
        logger: logger
      ).sanitize()
        +
        Sanitizer.unusedDependency(
          package: package,
          packageImport: packageImport,
          config: config,
          logger: logger
        ).sanitize()
        +
        Sanitizer.redundantImport(
          package: package,
          packageImport: packageImport,
          config: config,
          logger: logger
        ).sanitize()
        +
        Sanitizer.redundantDependency(
          package: package,
          packageImport: packageImport,
          config: config,
          logger: logger
        ).sanitize()
    }
  }
}

// MARK: - Sanitizer.ValidationError + Codable

extension Sanitizer.ValidationError: Codable {}

// MARK: - Sanitizer.MissingDependencyDetail + Codable

extension Sanitizer.MissingDependencyDetail: Codable {}

// MARK: - Sanitizer.UnusedDependencyDetail + Codable

extension Sanitizer.UnusedDependencyDetail: Codable {}

// MARK: - Sanitizer.RedundantImportDetail + Codable

extension Sanitizer.RedundantImportDetail: Codable {}

// MARK: - Sanitizer.RedundantDependencyDetail + Codable

extension Sanitizer.RedundantDependencyDetail: Codable {}
