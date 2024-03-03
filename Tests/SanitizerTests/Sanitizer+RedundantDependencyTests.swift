import Model
@testable import Sanitizer
import XCTest

// MARK: - RedundantDependencyTests

final class RedundantDependencyTests: XCTestCase {
  func testSanitizer_notDependingOnExportedDependency_noError() {
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeModule",
      exportedImports: ["SomeOtherModule"]
    )
    let dependencies = ["SomeModule"]
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.redundantDependency(
      package: test(from: sourceImport, dependencies: dependencies).0,
      packageImport: test(from: sourceImport, dependencies: dependencies).1,
      config: config,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 0)
  }

  func testSanitizer_dependingOnExportedDependency_errorReturned() {
    let sourceImports: SourceImport = .test(using: "SomeModule")
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeModule",
      exportedImports: ["SomeOtherModule"]
    )
    let dependencies = ["SomeModule", "SomeOtherModule"]
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.redundantDependency(
      package: test(from: sourceImports, dependencies: dependencies).0,
      packageImport: test(from: sourceImports, dependencies: dependencies).1,
      config: config,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertNotNil(result[0].redundantDependencyDetail)
    XCTAssertEqual(result[0].redundantDependencyDetail?.dependency.name, "SomeOtherModule")
  }
}

extension Sanitizer.ValidationError {
  fileprivate var redundantDependencyDetail: Sanitizer.RedundantDependencyDetail? {
    guard case .redundantDependency(let detail) = self else {
      return nil
    }

    return detail
  }
}
