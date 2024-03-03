import Model
@testable import Sanitizer
import XCTest

// MARK: - RedundantImportTests

final class RedundantImportTests: XCTestCase {
  func testSanitizer_notImportingExportedDependency_noError() {
    let sourceImport: SourceImport = .test(using: "SomeModule")
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeModule",
      exportedImports: ["SomeOtherModule"]
    )
    let dependencies = ["SomeModule"]
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.redundantImport(
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

  func testSanitizer_importingExportedDependency_errorReturned() {
    let sourceImports: [SourceImport] = .test(using: ["SomeModule", "SomeOtherModule"])
    let exportedImport: Configuration.ExportedImport = .init(
      importFramework: "SomeModule",
      exportedImports: ["SomeOtherModule"]
    )
    let dependencies = ["SomeModule"]
    let config = Configuration.Builder()
      .withExportedImport(exportedImport)
      .build()

    let subject = Sanitizer.redundantImport(
      package: test(from: sourceImports, dependencies: dependencies).0,
      packageImport: test(from: sourceImports, dependencies: dependencies).1,
      config: config,
      logger: .noop
    )

    // Act
    let result = subject.sanitize()

    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertNotNil(result[0].redundantImportDetail)
    XCTAssertEqual(result[0].redundantImportDetail?.sourceImport.module, "SomeOtherModule")
  }
}

extension Sanitizer.ValidationError {
  fileprivate var redundantImportDetail: Sanitizer.RedundantImportDetail? {
    guard case .redundantImport(let detail) = self else {
      return nil
    }

    return detail
  }
}
