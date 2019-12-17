// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public class ExistingCollectionLookupService: LookupService {
    public override func lookup(search: String, session: LookupSession) {
        
//        let context = session.context
//        context.perform {
//            let request: NSFetchRequest<Book> = context.fetcher()
//            request.predicate = NSPredicate(format: "(isbn = %@) or (name contains[cd] %@) or (SUBQUERY(relationships, $x, $x.person.name contains[cd] %@).@count > 0)", search, search, search)
//            request.sortDescriptors = []
//            if let results = try? context.fetch(request), results.count > 0 {
//                for book in results {
//                    if let relationships = book.relationships as? Set<Relationship> {
//                        let names = relationships.compactMap { $0.person?.name }
//                        let uniqueNames = Set(names)
//                        let candidate = ExistingCollectionLookupCandidate(book: book, service: self, authors: Array(uniqueNames))
//                        session.add(candidate: candidate)
//                    }
//                }
//                
//            }
//
//            session.done(service: self)
//        }
    }
}

public class ExistingCollectionLookupCandidate: LookupCandidate {
//    let book: Book
//
//    public init(book: Book, service: LookupService, authors: [String]) {
//        self.book = book
//        super.init(service: service, title: book.name, authors: authors, publisher: book.publisher?.name, date: book.published, image: book.imageURL)
//    }
//
//    public override var action: String { return "ViewCandidate" }
//
//    public override var existingBook: Book? {
//        return book
//    }
}
