// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that removes a relationship from a book.
 */

class RemovePublisherAction: BookAction {
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[PublisherAction.publisherKey] as? Publisher != nil)
        return info
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let publisher = context[PublisherAction.publisherKey] as? Publisher {
            for book in selection {
                publisher.remove(book)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(publisher: publisher)
            }
        }
        
    }
}
