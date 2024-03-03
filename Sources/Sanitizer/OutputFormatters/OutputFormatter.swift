import Foundation

/// A translator for converting errors to a `String` for output
public struct OutputFormatter {
  /// Given a collection of `ValidationError` instance, convert to
  /// a `String` format in a consumable form
  public var format: ([Sanitizer.ValidationError]) -> String
}
