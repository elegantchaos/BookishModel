// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

let headingColumnID = "heading"
let controlColumnID = "control"
let roleColumnID = "role"

public class DetailItem {
    public let kind: DetailSpec.Kind
    public let absolute: Int
    public let index: Int
    public let placeholder: Bool
    public weak var source: BookDetailProvider?
    
    public var heading: String {
        return "<unknown>"
    }
    
    public init(kind: DetailSpec.Kind, absolute: Int, index: Int, placeholder: Bool, source: BookDetailProvider? = nil) {
        self.kind = kind
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

public class SimpleDetailItem: DetailItem {
    override public var heading: String {
        return source?.details(for: self).label ?? super.heading
    }
}
