import Foundation

// MARK: - Configuration

/// The configuration file for the tool
public struct Configuration {
  // MARK: Lifecycle

  public init(
    swiftExecPath: URL,
    systemFrameworks: [String],
    exportedImports: [Configuration.ExportedImport],
    ignoredFrameworks: [Configuration.IgnoredFramework],
    ignoredTargets: [Configuration.IgnoredTarget],
    enableDebugLogging: Bool
  ) {
    self.swiftExecPath = swiftExecPath
    self.systemFrameworks = systemFrameworks
    self.exportedImports = exportedImports
    self.ignoredFrameworks = ignoredFrameworks
    self.ignoredTargets = ignoredTargets
    self.enableDebugLogging = enableDebugLogging
  }

  // MARK: Public

  public var swiftExecPath: URL
  public var systemFrameworks: [String]
  public var exportedImports: [ExportedImport]
  public var ignoredFrameworks: [IgnoredFramework]
  public var ignoredTargets: [IgnoredTarget]
  public var enableDebugLogging: Bool
}

// MARK: Configuration.IgnoredFramework

extension Configuration {
  /// A framework which imports of are not validated
  public struct IgnoredFramework {
    public var framework: String
    public var reason: String?
  }
}

// MARK: Configuration.IgnoredTarget

extension Configuration {
  /// A target which does not have its sources validated
  public struct IgnoredTarget {
    public var targetName: String
    public var reason: String?
  }
}

// MARK: Configuration.ExportedImport

extension Configuration {
  /// An framework that has one or more exported imports
  public struct ExportedImport {
    // MARK: Lifecycle

    public init(importFramework: String, exportedImports: [String]) {
      self.importFramework = importFramework
      self.exportedImports = exportedImports
    }

    // MARK: Public

    public var importFramework: String
    public var exportedImports: [String]
  }
}

extension Configuration {
  public static var empty: Self {
    .init(
      swiftExecPath: .init(fileURLWithPath: "/usr/bin/swift"),
      systemFrameworks: [],
      exportedImports: [],
      ignoredFrameworks: [],
      ignoredTargets: [],
      enableDebugLogging: false
    )
  }
}

extension Configuration {
  public static var name: String {
    ".dowyi.json"
  }
}

extension Configuration {
  public func isSystem(_ module: String) -> Bool {
    systemFrameworks.contains(module)
  }

  public func isIgnored(_ module: String) -> Bool {
    ignoredFrameworks.contains {
      $0.framework == module
    }
  }
}

extension Configuration {
  public static func readFromPath(
    _ paths: [URL],
    default: Configuration,
    logger: Logger
  )
    -> Self {
    for path in paths {
      let decoder = JSONDecoder()
      do {
        let json: Data = try .init(contentsOf: path)
        let config = try decoder.decode(Configuration.self, from: json)
        return config
      } catch {
        logger.log(.warning, "Failed to read config file, using default configuration")
      }
    }

    return `default`
  }
}

// MARK: Codable

extension Configuration: Codable {}

// MARK: - Configuration.IgnoredTarget + Codable

extension Configuration.IgnoredTarget: Codable {}

// MARK: - Configuration.IgnoredFramework + Codable

extension Configuration.IgnoredFramework: Codable {}

// MARK: - Configuration.ExportedImport + Codable

extension Configuration.ExportedImport: Codable {}
