import Foundation

// MARK: - SourceImport

/// A description of an import statement within a source file
public struct SourceImport {
  // MARK: Lifecycle

  public init(
    file: URL,
    lineNumber: Int,
    rawText: String,
    module: String
  ) {
    self.file = file
    self.lineNumber = lineNumber
    self.rawText = rawText
    self.module = module
  }

  // MARK: Public

  public var file: URL
  public var lineNumber: Int
  public var rawText: String
  public var module: String
}

// MARK: - TargetImport

/// A description of source imports contained within a Package target
public struct TargetImport {
  // MARK: Lifecycle

  public init(
    targetName: String,
    type: Target.TargetType,
    sourceImports: [SourceImport]
  ) {
    self.targetName = targetName
    self.sourceImports = sourceImports
  }

  // MARK: Public

  public var targetName: String
  public var sourceImports: [SourceImport]
}

// MARK: - PackageImport

/// A description of all imports across all targets within a Package
public struct PackageImport {
  // MARK: Lifecycle

  public init(
    targetImports: [TargetImport]
  ) {
    self.targetImports = targetImports
  }

  // MARK: Public

  public var targetImports: [TargetImport]
}

extension PackageImport {
  /// Create a package import description
  /// - Parameters:
  ///   - packageManifestDir: The directory containing the Package manifest
  ///   - package: The simplified Package description
  public init(
    packageManifestDir: URL,
    package: Package,
    fileSystem: FileSystem,
    logger: Logger
  ) {
    self.targetImports = package.targets.map {
      .init(
        targetName: $0.name,
        type: $0.type,
        sourceImports: $0.sourceImports(
          using: packageManifestDir,
          fileSystem: fileSystem,
          logger: logger
        )
      )
    }
  }
}

extension Target {
  /// Find all `SourceImport` for a `Target`
  /// - Parameter packageManifestDir: The directory containing the Package manifest
  /// - Returns: All `SourceImport` instances for the `Target`
  fileprivate func sourceImports(
    using packageManifestDir: URL,
    fileSystem: FileSystem,
    logger: Logger
  )
    -> [SourceImport] {
    var matches: [SourceImport] = []

    let sources = sources(
      using: packageManifestDir,
      filesystem: fileSystem,
      logger: logger
    )

    for source in sources {
      do {
        matches += try fileSystem.fileContents(source)
          .enumerated()
          .compactMap {
            SourceImport(
              file: source,
              line: String($1),
              number: $0 + 1
            )
          }
      } catch {
        logger.log(.warning, "Error processing file \(source.path)")
      }
    }

    return matches
  }

  /// Find all source file `URL` for the `Target`
  /// - Parameter packageManifestDir: The directory containing the Package manifest
  /// - Returns: All source files as `URL` instances for the `Target` honouring the
  /// target configuration settings
  private func sources(
    using packageManifestDir: URL,
    filesystem: FileSystem,
    logger: Logger
  )
    -> [URL] {
    let sourceDir = resolvedSourcesDir(baseDir: packageManifestDir)
    let files = filesystem.recursiveDirectoryContent(sourceDir)

    return files.compactMap { file in
      guard !file.hasDirectoryPath else { return nil }

      guard file.pathExtension == "swift" else {
        logger.log(.warning, "Skipping non source: \(file.path)")
        return nil
      }

      guard !isExcluded(file) else {
        logger.log(.warning, "Skipping excluded: \(file.path)")
        return nil
      }

      return file
    }
  }

  /// Get the top-level directory containing sources for the `Target`
  /// - Parameter baseDir: The base directory for which all paths for the `Target
  /// are relative to
  /// - Returns: The top-level directory containing sources for the `Target`
  private func resolvedSourcesDir(baseDir: URL) -> URL {
    guard let path = path else {
      let path: String

      switch type {
      case .executable, .regular:
        path = "Sources"
      case .test:
        path = "Tests"
      }

      return baseDir.appending(path: path).appending(path: name)
    }

    return baseDir.appending(path: path)
  }

  /// A predicate for determining if a given source file is containing by the `Target` or not
  /// - Parameter source: The source file `URL`
  /// - Returns: True if the source file belongs to the target, false otherwise
  private func isExcluded(_ source: URL) -> Bool {
    guard let exclude else { return false }
    return exclude.contains { excludePath in
      source.path.contains(excludePath)
    }
  }
}

extension SourceImport {
  /// From a line of Swift code, create an instance of `SourceImport`
  /// if that line contains a valid usage of an import statement
  ///
  /// - Parameters:
  ///   - file: The `URL` for the source file
  ///   - line: The line of code from the source file being processed
  ///   - number: The line number of the code being processed
  init?(file: URL, line: String, number: Int) {
    guard let moduleName = line.moduleName else {
      return nil
    }

    self.init(
      file: file,
      lineNumber: number,
      rawText: String(line),
      module: String(moduleName)
    )
  }
}

// MARK: - SourceImport + Codable

extension SourceImport: Codable {}

// MARK: - TargetImport + Codable

extension TargetImport: Codable {}

// MARK: - PackageImport + Codable

extension PackageImport: Codable {}
