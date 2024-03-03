import Foundation

extension Configuration {
  static var sample: Self = .init(
    swiftExecPath: URL(fileURLWithPath: "/usr/bin/swift"),
    systemFrameworks: [
      "Foundation",
      "SwiftUI",
    ],
    exportedImports: [
      .init(
        importFramework: "SomeFramework",
        exportedImports: [
          "SomeOtherFramework",
        ]
      ),
    ],
    ignoredFrameworks: [
      .init(
        framework: "MyModel",
        reason: "It's complicated"
      ),
    ],
    ignoredTargets: [
      .init(
        targetName: "MyTarget",
        reason: "It's also complicated"
      ),
    ],
    enableDebugLogging: false
  )
}

extension Configuration {
  public static var sampleJSON: String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try? encoder.encode(Configuration.sample)

    guard let data, let jsonString = String(data: data, encoding: .utf8) else {
      return .none
    }

    return jsonString
  }
}
