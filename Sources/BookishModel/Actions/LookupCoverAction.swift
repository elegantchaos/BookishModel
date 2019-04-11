// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

public class LookupCoverAction: SyncModelAction {
    public static let managerKey = "lookupManager"
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        
        if let manager = context[LookupCoverAction.managerKey] as? LookupManager,
            let books = context[ActionContext.selectionKey] as? [Book] {
            for book in books {
                if let isbn = book.isbn {
                    manager.lookup(ean: isbn, context: model) { (session, state) in
                        switch(state) {
                        case let .foundCandidate(candidate):
                            book.imageURL = candidate.image
                        default:
                            break
                        }
                    }
                }
            }
        }
        
    }
    
}
