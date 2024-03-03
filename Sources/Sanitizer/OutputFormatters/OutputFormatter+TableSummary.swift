import Foundation
import Utility

extension OutputFormatter {
  /// A formatter which displays all errors in a human readable table
  /// - Returns: The table formatter
  public static func tableSummary() -> Self {
    .init { errors in
      let rows = errors.enumerated().reduce([]) {
        $0 + [Table.getErrorRow($1.1, number: $1.0 + 1)]
      }

      return Table.header(errors.count) +
        "\n\n" +
        AnsiColor.withColor(.white, Table(rows: rows).description)
    }
  }
}

// MARK: - OutputFormatter.Table

extension OutputFormatter {
  fileprivate struct Table {
    var rows: [Row]
  }
}

// MARK: - OutputFormatter.Table.Row

extension OutputFormatter.Table {
  fileprivate struct Row {
    var columns: [Column]
  }
}

// MARK: - OutputFormatter.Table.ColumnDefinition

extension OutputFormatter.Table {
  fileprivate struct ColumnDefinition {
    var description: String
    var content: String
    var width: Int
  }
}

// MARK: - OutputFormatter.Table.Column

extension OutputFormatter.Table {
  fileprivate struct Column {
    var content: String
    var definition: ColumnDefinition
  }
}

extension OutputFormatter.Table {
  fileprivate static func header(_ errorCount: Int) -> String {
    guard errorCount != 0 else {
      return "No errors found!"
    }

    return AnsiColor.withColor(.red, "Number of errors found: \(errorCount)")
  }
}

extension OutputFormatter.Table {
  fileprivate static var columnDefinition1: ColumnDefinition {
    .init(
      description: "Number column",
      content: "",
      width: 6
    )
  }

  fileprivate static var columnDefinition2: ColumnDefinition {
    .init(
      description: "Target Name",
      content: "TargetName",
      width: 40
    )
  }

  fileprivate static var columnDefinition3: ColumnDefinition {
    .init(
      description: "Error Type",
      content: "Type",
      width: 25
    )
  }

  fileprivate static var columnDefinition4: ColumnDefinition {
    .init(
      description: "Error Message",
      content: "Details",
      width: 50
    )
  }

  fileprivate static func getTitleRow() -> Row {
    .init(
      columns: [
        .init(
          content: columnDefinition1.content,
          definition: columnDefinition1
        ),
        .init(
          content: columnDefinition2.content,
          definition: columnDefinition2
        ),
        .init(
          content: columnDefinition3.content,
          definition: columnDefinition3
        ),
        .init(
          content: columnDefinition4.content,
          definition: columnDefinition4
        ),
      ]
    )
  }

  fileprivate static func getErrorRow(
    _ error: Sanitizer.ValidationError,
    number: Int
  )
    -> Row {
    let column1: Column = .init(
      content: String(number) + ".",
      definition: columnDefinition1
    )

    let column2: Column = .init(
      content: error.targetName,
      definition: columnDefinition2
    )

    let column3: Column = .init(
      content: error.typeDescription,
      definition: columnDefinition3
    )

    let column4: Column = .init(
      content: error.message,
      definition: columnDefinition4
    )

    return .init(
      columns: [column1, column2, column3, column4]
    )
  }
}

// MARK: - OutputFormatter.Table + CustomStringConvertible

extension OutputFormatter.Table: CustomStringConvertible {
  var description: String {
    rows.reduce(rowSeparator) {
      """
      \($0)
      \($1.description)
      \(rowSeparator)
      """
    }
  }
}

// MARK: - OutputFormatter.Table.Row + CustomStringConvertible

extension OutputFormatter.Table.Row: CustomStringConvertible {
  var description: String {
    let columnDescriptions = columns.map {
      $0.description.split(separator: "\n")
    }

    let numberOfLines = columnDescriptions.map { $0.count }.max() ?? 0
    var lines: [String] = []

    for lineNumber in 0 ..< numberOfLines {
      var line = ""

      for (index, columnDescription) in columnDescriptions.enumerated() {
        guard lineNumber < columnDescription.count else {
          // No content for this column at this line - pad with space
          let width = columns[index].definition.width
          line += "".padding(toLength: width, withPad: " ", startingAt: 0)
          continue
        }

        line += String(columnDescription[lineNumber])
      }

      lines.append(line)
    }

    return lines.joined(separator: "\n")
  }
}

// MARK: - OutputFormatter.Table.Column + CustomStringConvertible

extension OutputFormatter.Table.Column: CustomStringConvertible {
  var description: String {
    content.split(separator: "\n")
      .map { $0.padding(toLength: definition.width, withPad: " ", startingAt: 0) }
      .joined(separator: "\n")
  }
}

extension OutputFormatter.Table {
  var rowSeparator: String {
    guard let firstRow = rows.first else { return "" }

    return String(
      repeating: "-",
      count: (firstRow.columns.reduce(0) { $0 + $1.definition.width }) - 1
    )
  }
}
