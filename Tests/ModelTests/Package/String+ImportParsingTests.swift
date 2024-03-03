@testable import Model
import XCTest

final class ModuleNameFromImportTests: XCTestCase {
  func testModuleNameFromImport_validMinimalImport_succeeds() {
    // Arrange
    let importSource = "import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_extraWhitespaceBeforeModuleName_succeeds() {
    // Arrange
    let importSource = "import      Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_extraWhitespaceAfterModuleName_succeeds() {
    // Arrange
    let importSource = "import      Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_whitespaceBeforeImport_succeeds() {
    // Arrange
    let importSource = "     import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_invalidMinimalImport_fails() {
    // Arrange
    let importSource = "garbage import Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertNil(result)
  }

  func testModuleNameFromImport_commentedImport_fails() {
    // Arrange
    let importSource = "// import Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertNil(result)
  }

  func testModuleNameFromImport_whitespaceBeforeCommentedImport_fails() {
    // Arrange
    let importSource = "   // import Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertNil(result)
  }

  func testModuleNameFromImport_missingModuleName_fails() {
    // Arrange
    let importSource = "import"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertNil(result)
  }

  func testModuleNameFromImport_withImportKindTypealias_succeeds() {
    // Arrange
    let importSource = "import typealias Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindStruct_succeeds() {
    // Arrange
    let importSource = "import struct Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindClass_succeeds() {
    // Arrange
    let importSource = "import class Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindEnum_succeeds() {
    // Arrange
    let importSource = "import enum Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindProtocol_succeeds() {
    // Arrange
    let importSource = "import protocol Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindLet_succeeds() {
    // Arrange
    let importSource = "import let Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindVar_succeeds() {
    // Arrange
    let importSource = "import var Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withImportKindFunc_succeeds() {
    // Arrange
    let importSource = "import func Swift.Void"
    let expected = "Swift"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withSpi_succeeds() {
    // Arrange
    let importSource = "@_spi(Private) import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withTestable_succeeds() {
    // Arrange
    let importSource = "@testable import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withExported_succeeds() {
    // Arrange
    let importSource = "@_exported import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withExportedThenSpi_succeeds() {
    // Arrange
    let importSource = "@_exported @_spi(Private) import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }

  func testModuleNameFromImport_withSpiThenExported_succeeds() {
    // Arrange
    let importSource = "@_spi(Private) @_exported import Foundation"
    let expected = "Foundation"

    // Act
    let result = importSource.moduleName

    // Assert
    XCTAssertEqual(result, expected)
  }
}
