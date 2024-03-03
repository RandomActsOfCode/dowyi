import Foundation

extension OutputFormatter {
  /// A formatter which displays all errors in a human readable table
  /// - Returns: The table formatter
  public static func json() -> Self {
    .init { errors in
      var json: String?
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted

      if let data = try? encoder.encode(errors) {
        json = String(data: data, encoding: .utf8)
      }

      guard let json else {
        return "Error generating JSON results"
      }

      return json
    }
  }
}
