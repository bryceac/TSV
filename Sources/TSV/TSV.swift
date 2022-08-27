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
        
        guard records.allSatisfy({record in
            record.count == longestRow.count
        }) else {
            let index = records.firstIndex(of: longestRow)!
            
            throw TSVParseError.columnsNotEqual(lineNumber: index+1)
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
        
        guard records.allSatisfy({record in
            record.count == longestRow.count
        }) else {
            let index = records.firstIndex(of: longestRow)!
            
            throw TSVParseError.columnsNotEqual(lineNumber: index+1)
        }
        
        columnHeadings = columns
        
        self.records = .none ~= columns ? Matrix(withGrid: records) : Matrix(columns: columns!.count, withGrid: records)
    }
    
    // MARK: Subscripts
    /**
     grab a row, not including header row, at a particular index.
     - parameter row: A zero-based index specifying a particular row.
     - Returns: A String array with the contents of the desired row.
     */
    public subscript(row: Int) -> [String] {
        return records[row]
    }
    
    /**
     grab a column, not including header row, at a particular index.
     - parameter column: A zero-based index specifying a particular column.
     - Returns: A String array with the contents of the desired column.
     */
    public subscript(column column: Int) -> [String] {
        return records[column: column]
    }
    
    /**
     Grab at value at a specified y,x coordinate, excluding the header.
     - Parameters:
        - row: A zero-based index specifying the row.
        - column: A Zero-based index specifying the column.
     - Returns: A String value at the specified coordinate.
     */
    public subscript(row: Int, column: Int) -> String {
        get {
            return records[row, column]
        }
        
        set {
            records[row, column] = newValue
        }
    }
    
    /**
     retrieve a column with a particular name, excluding headers.
     - parameter column: The name of the column to retrieve.
     - Returns: A String array of the items in a specified column.
     */
    public subscript(column: String) -> [String] {
        guard !contents.isEmpty else { return [] }
        
        return contents.filter { record in
            record.keys.contains(column)
        }.compactMap { record in
            record[column]
        }
    }
}

extension TSV: CustomStringConvertible {
    public var description: String {
        var content = ""
        
        if let columnHeadings = columnHeadings {
            content += "\(columnHeadings.joined(separator: "\t"))\n"
        }
        
        for record in records.grid {
            if records.grid.last != record {
                content += "\(record.joined(separator: "\t"))\n"
            } else {
                content += "\(record.joined(separator: "\t"))"
            }
        }
        
        return content
    }
}
