// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol BookViewer {
    func reveal(book: Book)
}

/**
 Objects that want to observe changes to books should
 implement this protocol.
 */

public protocol BookChangeObserver: ActionObserver {
    func added(books: [Book])
    func removed(books: [Book])
}

/**
 Common functionality for all book-related actions.
 */

open class BookAction: ModelAction {
    public static let bookKey = "book"

    open class override func standardActions() -> [Action] {
        return [
            NewBookAction(identifier: "NewBook"),
            DeleteBooksAction(identifier: "DeleteBooks"),
            RevealBookAction(identifier: "RevealBook")
        ]
    }
}

/**
 Action to inserts a new book.
 */

public class NewBookAction: BookAction {
    override public func perform(context: ActionContext, model: NSManagedObjectContext) {
        let book = Book(context: model)
        context.info.forObservers { (observer: BookChangeObserver) in
            observer.added(books: [book])
        }
    }
}

/**
 Action that deletes a book.
 */

public class DeleteBooksAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        guard let selection = context[ActionContext.selectionKey] as? [Book] else {
            return false
        }
        
        return selection.count > 0
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            for book in selection {
                model.delete(book)
            }
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(books: selection)
            }
        }
    }
    
}

/**
 Action that shows a book in the user interface.
 */

class RevealBookAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        let book = context[BookAction.bookKey] as? Book
        return (book != nil) && super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let book = context[BookAction.bookKey] as? Book,
            let viewer = context[ActionContext.rootKey] as? BookViewer {
            viewer.reveal(book: book)
        }
    }
}
