// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import Foundation

public class LookupCandidate: CustomStringConvertible {
    public let service: LookupService
    public let title: String
    public let authors: [String]
    public let publisher: String
    public let date: Date?
    public let image: String?
    
    public init(service: LookupService, title: String? = nil, authors: [String]? = [], publisher: String? = nil, date: Date? = nil, image: String? = nil) {
        self.title = title ?? ""
        self.authors = authors ?? []
        self.publisher = publisher ?? ""
        self.date = date
        self.service = service
        self.image = image
    }
    
    public var summary: String {
        return ""
    }
    
    public var action: String {
        return ""
    }
    
    public var existingBook: Book? {
        return nil
    }
    
    public func makeBook(in collection: CollectionContainer, completion: @escaping (EntityReference) -> Void) {
//        let book = Book(in: context)
//
//        book.name = title
//        book.imageURL = image
//        book.source = service.name
//
//        for author in authors {
//            let person = Person.named(author, in: context)
//            let relationship = person.relationship(as: Role.StandardName.author)
//            book.addToRelationships(relationship)
//        }
//
//        if !publisher.isEmpty {
//            book.publisher = Publisher.named(publisher, in: context)
//        }
//
//        book.published = date
//        completion(book)
    }
    
    public var description: String {
        get {
            return "<Candidate: \(title) \(authors) \(publisher)>"
        }
    }
}
