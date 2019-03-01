// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

class ExistingCollectionLookupService: LookupService {
    public override func lookup(search: String, session: LookupSession) {
        
        let context = session.collection.managedObjectContext
        
        let request: NSFetchRequest<Book> = context.fetcher()
        request.predicate = NSPredicate(format: "(isbn = \"\(search)\") or (ean = \"\(search)\")")
        request.sortDescriptors = []
        if let results = try? context.fetch(request), results.count > 0 {
            for book in results {
                var people = Set<Person>()
                if let relationships = book.relationships as? Set<Book> {
                    for relationship in relationships {
                        people.formUnion(relationship.people)
                    }
                    let authors = people.compactMap { $0.name }
                    let candidate = LookupCandidate(service: self, title: book.name, authors: authors, publisher: book.publisher?.name, date: book.published, image: book.imageURL)
                    session.add(candidate: candidate)
                }
            }
            
        }
        
        super.lookup(search: search, session: session)
    }
    
}
