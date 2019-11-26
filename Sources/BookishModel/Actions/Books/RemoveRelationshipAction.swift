

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that removes a relationship from a book.
 */

class RemoveRelationshipAction: BookAction {
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[PersonAction.relationshipKey] as? Relationship != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let relationship = context[PersonAction.relationshipKey] as? Relationship {
            for book in selection {
                book.removeFromRelationships(relationship)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(relationship: relationship)
            }
            
            if relationship.books.count == 0 {
                relationship.managedObjectContext?.delete(relationship)
            }
        }
        
    }
}
