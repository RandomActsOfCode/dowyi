import Foundation

/// Various color codes
public enum AnsiColor: String, RawRepresentable {
  case white = "\u{001B}[0;37m"
  case green = "\u{001B}[0;32m"
  case yellow = "\u{001B}[0;33m"
  case red = "\u{001B}[0;31m"
  case reset = "\u{001B}[0;0m"

  // MARK: Public

  /// Get the color code for a given enum case
  public var colorCode: String {
    guard ProcessInfo.processInfo.environment["NO_COLOR"] == nil else {
      return ""
    }

    return rawValue
  }

  /// Wrap a String in a color
  public static func withColor(_ color: AnsiColor, _ message: String) -> String {
    "\(color.colorCode)\(message)\(AnsiColor.reset.colorCode)"
  }
}
