//
//  File.swift
//  
//
//  Created by Bryce Campbell on 8/26/22.
//

import Foundation
public enum TSVError {
    case tooFewColumnHeadings, columnsNotEqual
}

extension TSVError: LocalizedError {
    public var errorDescription: String? {
        var error: String? = nil
        
        switch self {
        case .tooFewColumnHeadings: error = "The number of Headings be either be equal to or exceed the number of fields found in the longest row"
        case .columnsNotEqual: error = "All columns mist have an equal number of fields."
        }
        
        return error
    }
}
