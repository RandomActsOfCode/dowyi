import Foundation

// MARK: - SwiftDriver

/// A small wrapper offering functionality from the `swift` driver tool
public struct SwiftDriver {
  // MARK: Lifecycle

  public init(
    swiftToolPath: URL,
    packageDirectory: URL
  ) {
    self.swiftToolPath = swiftToolPath
    self.packageDirectory = packageDirectory
  }

  // MARK: Public

  public var swiftToolPath: URL
  public var packageDirectory: URL
}

// MARK: SwiftDriver.Package

extension SwiftDriver {
  /// The `swift` driver `package` subcommand
  public struct Package {
    public let swiftDriver: SwiftDriver
    public let command = "package"
  }
}

extension SwiftDriver {
  /// Get an instance of the `swift` driver `package` subcommand
  public var package: Package {
    .init(swiftDriver: self)
  }
}

extension SwiftDriver.Package {
  /// Invoke the `swift` driver `package` subcommand's `dump-package` utility
  /// - Returns: The deserialized JSON data
  public func dump() throws -> Data {
    var process = ExecuteProcess(
      tool: swiftDriver.swiftToolPath.path,
      arguments: [command, "dump-package"],
      cwd: swiftDriver.packageDirectory.path
    )

    let exit = process.run()

    switch exit {
    case .success(let result):
      guard let stdout = result.stdout else {
        throw Error.missingToolOutput
      }

      guard let json = stdout.data(using: .utf8) else {
        throw Error.badToolOutput
      }

      return json

    case .failure:
      throw Error.invokingToolFailed
    }
  }
}

// MARK: - SwiftDriver.Package.Error

extension SwiftDriver.Package {
  enum Error: Swift.Error {
    case invokingToolFailed
    case missingToolOutput
    case badToolOutput
  }
}
