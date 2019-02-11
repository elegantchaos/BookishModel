// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class PersonDetailItem: DetailItem {
    public let relationship: Relationship?
    
    public init(relationship: Relationship? = nil, absolute: Int, index: Int, source: DetailProvider) {
        self.relationship = relationship
        super.init(kind: "person", absolute: absolute, index: index, placeholder: relationship == nil, source: source)
    }
    
    public override var heading: String {
        return placeholder ? "Person" : relationship?.role?.name ?? super.heading
    }
    
    override public func viewID(for column: String) -> String { // TODO: move out of model?
        switch column {
        case headingColumnID:
            return roleColumnID
            
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
