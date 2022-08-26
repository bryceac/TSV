import Foundation
import Matrix

/// A representation of a TSV object
public struct TSV {
    /// the headings for the columns
    public var columnHeadings: [String]? = nil
    
    /// the records in the TSV
    public var records: Matrix<String>
    private var contents: [[String:String]] {
        guard let columnHeadings = columnHeadings else { return [] }
        
        return records.grid.map { record in
            record.enumerated().reduce(into: [:]) { recordDict, pair in
                let (index, value) = pair
                recordDict[columnHeadings[index]] = value
            }
        }
    }
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
    
    public init(columns: [String]? = nil, records: [[String]]) throws {
        let longestRow = records.max { firstRow, secondRow in
            firstRow.count < secondRow.count
        }!
        
        guard .none ~= columns && records.allSatisfy({ record in
            record.count == longestRow.count
        }) || !(.none ~= columns) && columns!.count >= longestRow.count else {
            if let _ = columns {
                throw TSVError.tooFewColumnHeadings
            } else {
                throw TSVError.columnsNotEqual
            }
        }
        
        columnHeadings = columns
        
        self.records = .none ~= columns ? Matrix(withGrid: records) : Matrix(columns: columns!.count, withGrid: records)
    }
}
