import ArgumentParser
import Foundation
import Live
import Model
import Sanitizer

// MARK: - Dowyi

@main
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/// A command line tool for checking that target dependencies
/// match all imported modules
struct Dowyi: ParsableCommand {
  @Flag(
    name: .shortAndLong,
    help: "Write an example configuration file to the current directory"
  )
  var writeConfiguration = false

  @Flag(
    name: .shortAndLong,
    help: "Enable debug logging"
  )
  var debugLogging = false

  @Option(
    name: .shortAndLong,
    help: "The directory containing the Swift Package manifest to validate"
  )
  var packageManifestDir: String?

  @Option(
    name: .shortAndLong,
    help: "The output format to display results in"
  )
  var outputFormat: OutputFormat = .table

  mutating func run() throws {
    ConsoleLogger.shared.debugLoggingEnabled = debugLogging
    let packageManifestDir = try resolvedPackageManifestDir()

    if writeConfiguration {
      generateSampleConfiguration(configFileDir: packageManifestDir)
    }

    let config = loadConfiguration(configFileDir: packageManifestDir)
    let package = try loadPackageManifest(config)
    let packageImport = PackageImport(
      packageManifestDir: packageManifestDir,
      package: package,
      fileSystem: FileManager.fileSystem(),
      logger: ConsoleLogger.logger()
    )

    let sanitizer: Sanitizer = .allChecks(
      package: package,
      packageImport: packageImport,
      config: config,
      logger: ConsoleLogger.logger()
    )

    let validationErrors = sanitizer.sanitize()
    let output: String

    switch outputFormat {
    case .table:
      let tableFormatter: OutputFormatter = .tableSummary()
      output = tableFormatter.format(validationErrors)
    case .json:
      let jsonFormatter: OutputFormatter = .json()
      output = jsonFormatter.format(validationErrors)
    }

    print(output)

    guard validationErrors.isEmpty else {
      throw ExitCode(.validationErrors(validationErrors))
    }
  }
}

extension Dowyi {
  fileprivate func loadConfiguration(configFileDir: URL) -> Configuration {
    let configFilePath = configFileDir.appending(path: Configuration.name)
    var config = Configuration.readFromPath(
      [configFilePath, URL(fileURLWithPath: FileManager.default.currentDirectoryPath)],
      default: .empty,
      logger: ConsoleLogger.logger()
    )
    config.enableDebugLogging = debugLogging
    return config
  }

  fileprivate func loadPackageManifest(_ config: Configuration) throws -> Package {
    let packageManifestDir = try resolvedPackageManifestDir()
    let package = try? Package.readFromSwiftPM(
      path: packageManifestDir,
      swiftToolPath: config.swiftExecPath
    )

    guard let package else {
      ConsoleLogger.shared.log(.error, "Unable to read package contents, check manifest for errors")
      throw ExitCode(.couldNotReadPackageManifest)
    }

    return package
  }
}

// MARK: - Computed Properties

extension Dowyi {
  /// Get the resolved directory for the Package manifest being analyzed.
  ///
  /// Note: this is either the user provided directory, or the current
  /// working directory if no Package manifest directory was provided
  fileprivate func resolvedPackageManifestDir() throws -> URL {
    let dir: URL

    if let packageManifestDir {
      dir = URL(fileURLWithPath: packageManifestDir)
    } else {
      dir = currentWorkingDirectory
    }

    let packageManifestPath = dir.appending(path: "Package.swift")

    guard FileManager.default.fileExists(atPath: packageManifestPath.path) else {
      ConsoleLogger.shared.log(.error, "No package manifest found")
      throw ExitCode(.packageManifestNotFound)
    }

    return dir
  }

  /// Get the current working directory for the tool
  fileprivate var currentWorkingDirectory: URL {
    .init(fileURLWithPath: Process().currentDirectoryPath)
  }

  /// Get the expected location for the tool's configuration file
  fileprivate var defaultConfigPath: URL {
    currentWorkingDirectory.appending(path: Configuration.name)
  }
}

extension Dowyi {
  /// Generate a sample configuration file to the expected
  /// configuration file path
  fileprivate func generateSampleConfiguration(configFileDir: URL) {
    guard let json = Configuration.sampleJSON else {
      fatalError("Internal error: Could not generate sample config file")
    }

    let configFilePath = configFileDir.appending(path: Configuration.name)

    FileManager.default.createFile(
      atPath: configFilePath.path,
      contents: json.data(using: .utf8)
    )

    ConsoleLogger.shared.log(
      .status,
      "Created config file at \(configFilePath.path)"
    )
  }
}

extension Int32 {
  /// The Swift Package Manifest could not be found for processing
  static var packageManifestNotFound = Self(-1)

  /// The Swift Package Manifest could not be read
  static var couldNotReadPackageManifest = Self(-2)

  /// The Swift Package Manifest had validation errors, count as error code
  static func validationErrors(_ errors: [Sanitizer.ValidationError]) -> Int32 {
    Int32(errors.count)
  }
}

extension Package {
  /// Read the Package manifest using the SwiftPM functionality embedded within the
  /// `swift` driver tool
  /// - Parameters:
  ///   - path: The directory containing the Package manifest
  ///   - config: The configuration file used by this tool
  /// - Returns: The deserialized simplified Package manifest, or `.none` on error
  static func readFromSwiftPM(
    path: URL,
    swiftToolPath: URL = URL(fileURLWithPath: "/usr/bin/swift")
  ) throws
    -> Package? {
    let swiftDriver = SwiftDriver(swiftToolPath: swiftToolPath, packageDirectory: path)
    let json = try swiftDriver.package.dump()
    let package = try JSONDecoder().decode(Package.self, from: json)
    return package
  }
}

// MARK: - Dowyi.OutputFormat

extension Dowyi {
  enum OutputFormat: String {
    case table
    case json
  }
}

// MARK: - Dowyi.OutputFormat + Codable

extension Dowyi.OutputFormat: Codable {}

// MARK: - Dowyi.OutputFormat + ExpressibleByArgument

extension Dowyi.OutputFormat: ExpressibleByArgument {}
