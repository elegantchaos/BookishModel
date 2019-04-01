// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ExistingCollectionLookupService: LookupService {
    public override func lookup(search: String, session: LookupSession) {
        
        let context = session.collection.managedObjectContext
        context.perform {
            let request: NSFetchRequest<Book> = context.fetcher()
            request.predicate = NSPredicate(format: "(isbn = \"\(search)\") or (ean = \"\(search)\")")
            request.sortDescriptors = []
            if let results = try? context.fetch(request), results.count > 0 {
                for book in results {
                    if let relationships = book.relationships as? Set<Relationship> {
                        let names = relationships.compactMap { $0.person?.name }
                        let uniqueNames = Set(names)
                        let candidate = LookupCandidate(service: self, title: book.name, authors: Array(uniqueNames), publisher: book.publisher?.name, date: book.published, image: book.imageURL)
                        session.add(candidate: candidate)
                    }
                }
                
            }

            session.done(service: self)
        }
    }
    
}
