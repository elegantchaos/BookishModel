// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action to inserts a new book.
 */

public class NewBookAction: BookAction {
    public override func validate(context: ActionContext) -> Validation {
        // we don't need a selection, so we skip to ModelAction's validation
        return modelValidate(context: context)
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//        let book = Book(context: model)
//        context.info.forObservers { (observer: BookLifecycleObserver) in
//            observer.created(books: [book])
//        }
    }
}
