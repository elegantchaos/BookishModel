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
    
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        if info.enabled {
            let books = context[ActionContext.selectionKey] as? [Book]
            info.enabled = (books != nil) && (context[LookupCoverAction.managerKey] != nil)
        }
        return info
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let manager = context[LookupCoverAction.managerKey] as? LookupManager,
            let books = context[ActionContext.selectionKey] as? [Book] {
            for book in books {
                lookupByISBN(book: book, manager: manager, context: model)
            }
        }
    }
    
    func lookupByISBN(book: Book, manager: LookupManager, context: NSManagedObjectContext) {
        if let isbn = book.isbn {
            var replaced = false
            _ = manager.lookup(query: isbn, context: context) { (session, state) in
                switch(state) {
                case let .foundCandidate(candidate):
                    if !replaced && !(candidate is ExistingCollectionLookupCandidate) {
                        book.imageURL = candidate.image
                        replaced = true
                    }
                case .done:
                    // if we got no hits with isbn, try a free text search combining the title, author(s) and publisher
                    if !replaced {
                        self.lookupByMetadata(book: book, manager: manager, context: context)
                    }
                default:
                    break
                }
            }
        } else {
            lookupByMetadata(book: book, manager: manager, context: context)
        }
    }
    
    func lookupByMetadata(book: Book, manager: LookupManager, context: NSManagedObjectContext) {
        var items: [String] = []
        if let name = book.name {
            items.append("intitle:\"\(name)\"")
        }
        if let relationships = book.relationships as? Set<Relationship> {
            for relationship in relationships {
                if let name = relationship.person?.name, let role = relationship.role?.uuid, role == "standard-author" {
                    items.append("inauthor:\"\(name)\"")
                }
            }
        }
        
        if items.count > 0 {
            var replaced = false
            let query = items.joined(separator: "+")
            print(query)
            _ = manager.lookup(query: query, context: context) { (session, state) in
                switch(state) {
                case let .foundCandidate(candidate):
                    if !replaced && !(candidate is ExistingCollectionLookupCandidate) {
                        book.imageURL = candidate.image
                        replaced = true
                    }
                default:
                    break
                }
            }
        }
    }
}

public class AddCandidateAction: LookupAction {
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let candidate = context[LookupAction.candidateKey] as? LookupCandidate, let viewer = context[ActionContext.rootKey] as? BookViewer {
            let book = candidate.makeBook(in: model)
            viewer.reveal(book: book)
        }
    }
}

public class ViewCandidateAction: LookupAction {
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
