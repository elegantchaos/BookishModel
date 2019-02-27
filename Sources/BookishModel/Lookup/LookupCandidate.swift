// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class LookupCandidate {
    public let service: LookupService
    
    public init(service: LookupService) {
        self.service = service
    }
    
    public var summary: String {
        return ""
    }
    
    public func makeBook(in context: NSManagedObjectContext) -> Book {
        let book = Book(in: context)
        return book
    }
}
