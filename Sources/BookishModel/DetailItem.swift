// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class DetailItem {
    public typealias ActionSpec = (String, String, Any)

    static let headingColumnID = "heading"
    static let controlColumnID = "control"
    static let unknownHeadingID = "<unknown>"
    

    public let kind: String
    public let absolute: Int
    public let index: Int
    public let placeholder: Bool
    public let source: DetailProvider
    
    public var heading: String {
        return DetailItem.unknownHeadingID
    }
    
    public var removeAction: ActionSpec? {
        return nil
    }
    
    public init(kind: String, absolute: Int, index: Int, placeholder: Bool, source: DetailProvider) {
        self.kind = kind
        self.absolute = absolute
        self.index = index
        self.placeholder = placeholder
        self.source = source
    }
    
    public func viewID(for column: String) -> String { // TODO: move out of model?
        switch column {
        case DetailItem.headingColumnID:
            return DetailItem.headingColumnID
            
        case DetailItem.controlColumnID:
            return DetailItem.controlColumnID
            
        default:
            return kind
        }
    }
}
