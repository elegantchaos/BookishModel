// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that shows a book in the user interface.
 */

class RevealBookAction: SyncModelAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && ((context[BookAction.bookKey] as? Book) != nil)
        return info
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let book = context[BookAction.bookKey] as? Book {
            context.info.forObservers { (viewer: BookViewer) in
                viewer.reveal(book: book, dismissPopovers: true)
            }
        }
    }
}
