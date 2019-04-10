// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class RelationshipDetailItem: DetailItem {
    static let roleColumnID = "role"

    public var relationship: Relationship? { return object as? Relationship }
    
    public init(relationship: Relationship? = nil, absolute: Int, index: Int, source: DetailProvider) {
        super.init(kind: "relationship", absolute: absolute, index: index, placeholder: relationship == nil, source: source, object: relationship)
    }
    
    public override var heading: String {
        return placeholder ? "Person" : relationship?.role?.name ?? super.heading
    }
    
    override public func viewID(for column: String) -> String { // TODO: move out of model?
        switch column {
        case DetailItem.headingColumnID:
            return RelationshipDetailItem.roleColumnID
            
        default:
            return super.viewID(for: column)
        }
    }
    
    public override var removeAction: DetailItem.ActionSpec? {
        if let relationship = relationship {
            return ( PersonAction.relationshipKey, "button.RemoveRelationship", relationship )
        } else {
            return super.removeAction
        }
    }

    
}
