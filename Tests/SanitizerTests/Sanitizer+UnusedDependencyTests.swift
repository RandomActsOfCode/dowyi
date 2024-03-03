import Model
@testable import Sanitizer
import XCTest

// MARK: - UnusedDependencyTests

final class UnusedDependencyTests: XCTestCase {
  func testSanitizer_dependencyIsUsed_noError() {
    // Arrange
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let dependencies = ["SomeModule"]

    let subject = Sanitizer.unusedDependency(
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

  func testSanitizer_dependencyIsNotUsed_errorReturned() {
    let sourceImport: SourceImport = .test(using: "Foundation")
    let dependencies = ["SomeModule"]

    let subject = Sanitizer.unusedDependency(
      package: test(from: sourceImport, dependencies: dependencies).0,
      packageImport: test(from: sourceImport, dependencies: dependencies).1,
      config: .fake,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertNotNil(result[0].unusedDependencyDetail)
    XCTAssertEqual(result[0].unusedDependencyDetail?.dependency.name, "SomeModule")
  }
}

extension Sanitizer.ValidationError {
  fileprivate var unusedDependencyDetail: Sanitizer.UnusedDependencyDetail? {
    guard case .unusedDependency(let detail) = self else {
      return nil
    }

    return detail
  }
}
