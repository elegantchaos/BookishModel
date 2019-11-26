// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that adds a relationship between a book and a newly created Publisher.
 */

class AddPublisherAction: BookAction {
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion()
//        if
//            let selection = context[ActionContext.selectionKey] as? [Book] {
//            let publisher = Publisher(context: model)
//            for book in selection {
//                publisher.add(book)
//            }
//            
//            context.info.forObservers { (observer: BookChangeObserver) in
//                observer.added(publisher: publisher)
//            }
//        }
    }
}
