// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

public class LookupAction: SyncModelAction {
    public static let candidateKey = "candidate"

    override open class func standardActions() -> [Action] {
        return [
            LookupCoverAction(),
            ViewCandidateAction(),
            AddCandidateAction(),
        ]
    }
}

public class LookupCoverAction: LookupAction {
    public static let managerKey = "lookupManager"
    
    public override func validate(context: ActionContext) -> Bool {
        let books = context[ActionContext.selectionKey] as? [Book]
        return (books != nil) && (context[LookupCoverAction.managerKey] != nil) && super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        
        if let manager = context[LookupCoverAction.managerKey] as? LookupManager,
            let books = context[ActionContext.selectionKey] as? [Book] {
            for book in books {
                if let isbn = book.isbn {
                    _ = manager.lookup(ean: isbn, context: model) { (session, state) in
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

public class AddCandidateAction: LookupAction {
    public override func validate(context: ActionContext) -> Action.Validation {
        return .init(enabled: true, visible: true, name: "Add")
    }

    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let candidate = context[LookupAction.candidateKey] as? LookupCandidate, let viewer = context[ActionContext.rootKey] as? BookViewer {
            let book = candidate.makeBook(in: model)
            viewer.reveal(book: book)
        }
    }
}

public class ViewCandidateAction: LookupAction {
    public override func validate(context: ActionContext) -> Action.Validation {
        return .init(enabled: true, visible: true, name: "View")
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let candidate = context[LookupAction.candidateKey] as? LookupCandidate,
            let viewer = context[ActionContext.rootKey] as? BookViewer,
            let book = candidate.existingBook
        {
            viewer.reveal(book: book)
        }
    }
}
