import Foundation
import Matrix

/// A representation of a TSV object
public struct TSV {
    /// the headings for the columns
    public var columnHeadings: [String]? = nil
    public var records: Matrix<String>
}

extension TSV {
    public init(_ text: String, withHeaders: Bool = false) throws {
        let contents = text.components(separatedBy: .newlines).map { line in
            line.components(separatedBy: "\t")
        }
        
        let records = withHeaders ? Array(contents.dropFirst()) : contents
        
        let longestRow = records.max { firstRow, secondRow in
            firstRow.count < secondRow.count
        }!
        
        guard withHeaders && contents[0].count >= longestRow.count || !withHeaders && records.allSatisfy({ record in
            record.count == longestRow.count
        }) else {
            let index = records.firstIndex(of: longestRow)!
            
            if withHeaders {
                throw TSVParseError.tooFewColumnHeadings(lineNumber: index+1)
            } else {
                throw TSVParseError.columnsNotEqual(lineNumber: index+1)
            }
        }
        
        if withHeaders {
            columnHeadings = contents[0]
            self.records = Matrix(columns: contents[0].count, withGrid: records)
        } else {
            self.records = Matrix(withGrid: records)
        }
    }
}
