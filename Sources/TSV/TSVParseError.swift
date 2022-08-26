//
//  File.swift
//  
//
//  Created by Bryce Campbell on 8/26/22.
//

import Foundation

public enum TSVParseError {
    case tooFewColumnHeadings(lineNumber: Int), columnsNotEqual(lineNumber: Int)
}

extension TSVParseError: LocalizedError {
    public var errorDescription: String? {
        var error: String? = nil
        
        switch self {
        case let .tooFewColumnHeadings(line): error = "The number of headings must equal or exceed the number of columns found on line \(line)."
        case let .columnsNotEqual(line): error = "All records must have the number of columns as line \(line)."
        }
        
        return error
    }
}

extension TSVParseError: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.tooFewColumnHeadings(let firstLine), .tooFewColumnHeadings(let secondLine)): return firstLine == secondLine
        case (.columnsNotEqual(let firstLine), .columnsNotEqual(let secondLine)): return firstLine == secondLine
        default: return false
        }
    }
}
