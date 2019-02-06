// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

let headingColumnID = "heading"
let controlColumnID = "control"
let roleColumnID = "role"

public struct DetailItem {
    public let kind: DetailSpec.Kind
    public let category: Category
    public let absolute: Int
    public let index: Int
    public let placeholder: Bool
    public weak var source: BookDetailProvider?
    
        public enum Category {
            case detail
            case person
            case publisher
            case series
        }
    
    public init(kind: DetailSpec.Kind, category: Category, absolute: Int, index: Int, placeholder: Bool, source: BookDetailProvider? = nil) {
        self.kind = kind
        self.category = category
        self.absolute = absolute
        self.index = index
        self.placeholder = placeholder
        self.source = source
    }
    
    
    public func viewID(for column: String) -> String { // TODO: move out of model?
        switch column {
        case headingColumnID:
            return kind == .person ? roleColumnID : headingColumnID
            
        case controlColumnID:
            return controlColumnID
            
        default:
            return kind.rawValue
        }
    }
}
