// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData
import Logger

let bookActionChannel = Logger("BookActions")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol BookViewer {
    func reveal(book: Book)
}

/**
 Objects that want to observe changes to the
 book should implement this protocol.
 */

public protocol BookChangeObserver: ActionObserver {
    func added(relationship: Relationship)
    func removed(relationship: Relationship)
    func replaced(relationship: Relationship, with: Relationship)
    func added(series: Series, position: Int)
    func removed(series: Series)
    func changed(series: Series, to: Series, position: Int)
    func added(publisher: Publisher)
    func changed(publisher: Publisher, to: Publisher)
    func removed(publisher: Publisher)
}

public extension BookChangeObserver {
    func added(relationship: Relationship) {
    }
    
    func removed(relationship: Relationship) {
    }
    
    func replaced(relationship: Relationship, with: Relationship) {
    }
    
    func added(series: Series, position: Int) {
    }
    
    func removed(series: Series) {
    }
    
    func changed(series: Series, to: Series, position: Int) {
    }
    
    func added(publisher: Publisher) {
    }
    
    func changed(publisher: Publisher, to: Publisher) {
    }

    func removed(publisher: Publisher) {
    }
}

/**
 Objects that want to observe changes to books should
 implement this protocol.
 */

public protocol BookLifecycleObserver: ActionObserver {
    func created(books: [Book])
    func deleted(books: [Book])
}

/**
 Common functionality for all book-related actions.
 */

open class BookAction: SyncModelAction {
    public static let bookKey = "book"
    
    open class override func standardActions() -> [Action] {
        return [
            NewBookAction(),
            DeleteBookAction(),
            AddPublisherAction(),
            RemovePublisherAction(),
            ChangePublisherAction(),
            AddRelationshipAction(),
            RemoveRelationshipAction(),
            ChangeRelationshipAction(),
            AddSeriesAction(),
            RemoveSeriesAction(),
            RevealBookAction()
        ]
    }
    
    open override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        
        if info.enabled, let selection = context[ActionContext.selectionKey] as? [Book] {
            info.enabled = selection.count > 0
        } else {
            info.enabled = false
        }
        return info
    }
}




