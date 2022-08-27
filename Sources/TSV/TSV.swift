import Foundation
import Matrix

/// A representation of a TSV object
public struct TSV {
    
    // MARK: Properties
    /// the headings for the columns
    public var columnHeadings: [String]? = nil
    
    private var records: Matrix<String>
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
    // MARK: Initializers
    /**
     create an instance of a TSV from a string.
     - Parameters:
        - text: The text to parse
        - withHeaders: denotes whether columns have headings or not. Default is false.
     - Returns: TSV object
     - Throws: `TSVParseError.tooFewColumnHeadings` if the number of headings is insufficent or `TSVParseError.columnsNotEqual` if the number of columns are not equal and **withHeader** is false.
     */
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
    
    /**
     create TSV object using arrays.
     - Parameters:
        - columns: The column headings. Defaults to nil
        - records: The records in to be found in the TSV.
     - Returns: TSV object
     - Throws: `TSVError.tooFewColumnHeadings` if **columns** is not nil and does not have a sufficent number of headings or `TSVError.columnsNotEqual` if **columns** is nil and the records vary in the number of fields contained.
     */
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
    
    // MARK: Subscripts
    public subscript(row: Int) -> [String] {
        return records[row]
    }
    
    public subscript(column column: Int) -> [String] {
        return records[column: column]
    }
}
