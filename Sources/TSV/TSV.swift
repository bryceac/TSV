import Foundation
import Matrix

/// A representation of a TSV object
public struct TSV {
    /// the headings for the columns
    public var columnHeadings: [String]? = nil
    public var records: Matrix<String>
}

extension TSV {
    init(_ text: String, withHeaders: Bool = false) {}
}
