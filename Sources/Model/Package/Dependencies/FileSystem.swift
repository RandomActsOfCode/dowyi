import Foundation

/// A type for accessing the FileSystem
public struct FileSystem {
  // MARK: Lifecycle

  /// Create an instance of FileSystem
  /// - Parameters:
  ///   - fileContents: An endpoint for reading file contents
  ///   - recursiveDirectoryContent: An endpoint for listing directory contents
  public init(
    fileContents: @escaping (URL) throws -> [String],
    recursiveDirectoryContent: @escaping (URL) -> [URL]
  ) {
    self.fileContents = fileContents
    self.recursiveDirectoryContent = recursiveDirectoryContent
  }

  // MARK: Public

  /// An endpoint for reading file contents
  public var fileContents: (URL) throws -> [String]

  /// An endpoint for listing directory contents
  public var recursiveDirectoryContent: (URL) -> [URL]
}
