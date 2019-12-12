// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that removes a relationship from a book.
 */

class RemovePublisherAction: EntityAction {
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[.publisherKey] as? Publisher != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if
            let selection = context[.selection] as? [Book],
            let publisher = context[.publisherKey] as? Publisher {
            for book in selection {
                publisher.remove(book)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(publisher: publisher)
            }
        }
        
    }
}
