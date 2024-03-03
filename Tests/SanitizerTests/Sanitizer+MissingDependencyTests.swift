import Model
@testable import Sanitizer
import XCTest

// MARK: - MissingDependencyTests

final class MissingDependencyTests: XCTestCase {
  func testSanitizer_dependencyExists_noError() {
    // Arrange
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let dependencies = ["SomeModule"]

    let subject = Sanitizer.missingDependencySanitizer(
      package: test(from: sourceImport, dependencies: dependencies).0,
      packageImport: test(from: sourceImport, dependencies: dependencies).1,
      config: .fake,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 0)
  }

  func testSanitizer_dependencyAreMissing_errorReturned() {
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let dependencies: [String] = .init()

    let subject = Sanitizer.missingDependencySanitizer(
      package: test(from: sourceImport, dependencies: dependencies).0,
      packageImport: test(from: sourceImport, dependencies: dependencies).1,
      config: .fake,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertNotNil(result[0].missingDependencyDetail)
    XCTAssertEqual(result[0].missingDependencyDetail?.sourceImport.module, sourceImport.module)
  }

  func testSanitizer_exportedByIncludedDependency_noError() {
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeOtherModule",
      exportedImports: ["SomeModule"]
    )
    let dependencies = ["SomeOtherModule"]
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.missingDependencySanitizer(
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

  func testSanitizer_exportedByNotIncludedDependency_errorReturned() {
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeOtherModule",
      exportedImports: ["SomeModule"]
    )
    let dependencies: [String] = []
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.missingDependencySanitizer(
      package: test(from: sourceImport, dependencies: dependencies).0,
      packageImport: test(from: sourceImport, dependencies: dependencies).1,
      config: config,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertNotNil(result[0].missingDependencyDetail)
    XCTAssertEqual(result[0].missingDependencyDetail?.sourceImport.module, sourceImport.module)
  }
}

extension Sanitizer.ValidationError {
  fileprivate var missingDependencyDetail: Sanitizer.MissingDependencyDetail? {
    guard case .missingDependency(let detail) = self else {
      return nil
    }

    return detail
  }
}
