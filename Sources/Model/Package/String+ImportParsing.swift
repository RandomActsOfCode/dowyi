import Foundation
import RegexBuilder

extension String {
  /// From a line of code, extract the imported module name if it exists
  ///
  /// See a description of the grammar:
  /// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/summaryofthegrammar/
  var moduleName: String? {
    let spiAttribute = Regex {
      "@_spi("
      OneOrMore(.word)
      ")"
    }

    let exportedAttribute = Regex {
      "@_exported"
    }

    let testableAttribute = Regex {
      "@testable"
    }

    let compilerAttributeType = ChoiceOf {
      spiAttribute
      exportedAttribute
      testableAttribute
    }

    let compilerAttribute = Optionally {
      compilerAttributeType
      OneOrMore(.whitespace)
    }

    let importKindType = ChoiceOf {
      "typealias"
      "struct"
      "class"
      "enum"
      "protocol"
      "let"
      "var"
      "func"
    }

    let importKind = Optionally {
      importKindType
      OneOrMore(.whitespace)
    }

    let importLineRegex = Regex {
      Anchor.startOfLine
      ZeroOrMore(.whitespace)
      ZeroOrMore {
        compilerAttribute
      }
      ZeroOrMore(.whitespace)
      "import"
      OneOrMore(.whitespace)
      importKind
      Capture {
        OneOrMore(.word)
      }
    }

    guard let match = firstMatch(of: importLineRegex) else {
      return nil
    }

    return String(match.output.1)
  }
}
