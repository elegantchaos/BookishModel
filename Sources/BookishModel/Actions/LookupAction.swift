// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

extension ActionKey {
    public static let candidateKey: ActionKey = "candidate"
}

public class LookupAction: ModelAction {

    override open class func standardActions() -> [Action] {
        return [
            LookupCoverAction(),
            ViewCandidateAction(),
            AddCandidateAction(),
        ]
    }
}

//extension ActionKey {
//    public static let managerKey: ActionKey = "lookupManager"
//}

public class LookupCoverAction: LookupAction {
    
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        if info.enabled {
            let books = context[.selection] as? [Book]
            info.enabled = (books != nil) && (context[.managerKey] != nil)
        }
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion(.ok)
//        if let manager = context[LookupCoverAction.managerKey] as? LookupManager,
//            let books = context[.selection] as? [Book] {
//            for book in books {
//                lookupByISBN(book: book, manager: manager, context: model)
//            }
//        }
    }
    
    func lookupByISBN(book: Book, manager: LookupManager, in store: Datastore) {
        if let isbn = book.isbn {
            var replaced = false
            _ = manager.lookup(query: isbn, in: store) { (session, state) in
                switch(state) {
                case let .foundCandidate(candidate):
                    if !replaced && !(candidate is ExistingCollectionLookupCandidate) {
                        book.imageURL = candidate.image
                        replaced = true
                    }
                case .done:
                    // if we got no hits with isbn, try a free text search combining the title, author(s) and publisher
                    if !replaced {
                        self.lookupByMetadata(book: book, manager: manager, in: store)
                    }
                default:
                    break
                }
            }
        } else {
            lookupByMetadata(book: book, manager: manager, in: store)
        }
    }
    
    func lookupByMetadata(book: Book, manager: LookupManager, in store: Datastore) {
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
            _ = manager.lookup(query: query, in: store) { (session, state) in
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
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let candidate = context[.candidateKey] as? LookupCandidate {
            candidate.makeBook(in: store) { book in
                context.info.forObservers { (viewer: BookViewer) in
                    viewer.reveal(book: book, dismissPopovers: false)
                }
                completion(.ok)
            }
        }
    }
}

public class ViewCandidateAction: LookupAction {
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let candidate = context[.candidateKey] as? LookupCandidate, let book = candidate.existingBook {
            context.info.forObservers { (viewer: BookViewer) in
                viewer.reveal(book: book, dismissPopovers: true)
            }
        }
    }
}
