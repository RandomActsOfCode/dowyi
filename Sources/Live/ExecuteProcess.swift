import Foundation

// MARK: - ExecuteProcess

/// A smaller wrapper for invoking commands
struct ExecuteProcess {
  // MARK: Lifecycle

  public init(
    tool: String,
    arguments: [String],
    cwd: String? = nil
  ) {
    self.tool = tool
    self.arguments = arguments
    self.cwd = cwd
  }

  // MARK: Public

  public var tool: String
  public var arguments: [String]
  public var cwd: String?
}

// MARK: ExecuteProcess.ProcessTermination

extension ExecuteProcess {
  /// The result of a process terminating successfully
  public struct ProcessTermination {
    // MARK: Lifecycle

    public init(
      exitCode: Int32,
      stdout: String? = nil
    ) {
      self.exitCode = exitCode
      self.stdout = stdout
    }

    // MARK: Public

    public var exitCode: Int32
    public var stdout: String?
  }
}

// MARK: ExecuteProcess.ProcessTerminationError

extension ExecuteProcess {
  /// The result of a process terminating with errors
  struct ProcessTerminationError: Error {
    var exitCode: Int32
    var stderr: String?
  }
}

extension ExecuteProcess {
  /// Execute the configured process and report back results
  mutating func run() -> Result<ProcessTermination, ProcessTerminationError> {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: tool)
    task.arguments = arguments

    if let cwd {
      task.currentDirectoryPath = cwd
    }

    let stdout = Pipe()
    let stderr = Pipe()
    task.standardOutput = stdout
    task.standardError = stderr

    do {
      try task.run()
      task.waitUntilExit()

      guard task.terminationStatus == 0 else {
        return .failure(.init(exitCode: task.terminationStatus, stderr: .init(pipe: stderr)))
      }

      return .success(.init(exitCode: task.terminationStatus, stdout: .init(pipe: stdout)))
    } catch {
      return .failure(.init(exitCode: task.terminationStatus, stderr: .init(pipe: stderr)))
    }
  }
}

extension Optional where Wrapped == String {
  /// Convenience initializer for extracting a String from a Pipe`
  /// - Parameter pipe: The pipe to extract the String from
  init(pipe: Pipe) {
    self = String(
      data: pipe.fileHandleForReading.readDataToEndOfFile(),
      encoding: .utf8
    )
  }
}
