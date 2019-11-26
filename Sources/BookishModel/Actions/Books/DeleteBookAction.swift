// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that deletes a book.
 */

public class DeleteBookAction: BookAction {
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion()
//        if let selection = context[ActionContext.selectionKey] as? [Book] {
//            for book in selection {
//                model.delete(book)
//            }
//            context.info.forObservers { (observer: BookLifecycleObserver) in
//                observer.deleted(books: selection)
//            }
//        }
    }
    
}

