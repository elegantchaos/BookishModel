// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Relationship: ModelObject {
    
    /**
     We should only have one entry for a given person/role pair, so the uuid is derived from their uuids.
     */
    
    public override var uniqueIdentifier: NSObject {
        guard let personID = person?.uuid, let roleID = role?.uuid else {
            return ModelObject.missingUUID
        }
        
        return "\(personID)-\(roleID)" as NSString
    }

    /**
     Since the uuid is calculated, we don't need to assign one initially.
     */
    
    override func assignInitialUUID() {
    }

    public var books: Set<Book> {
        get { return booksR as! Set<Book> }
        set { booksR = newValue as NSSet }
    }
    
    public func books(sortedBy sort: [NSSortDescriptor]) -> [Book] {
        return booksR?.sortedArray(using: sort) as! [Book]
    }
    
    public func add(_ book: Book) {
        addToBooksR(book)
    }
    
    public func add(_ books: Set<Book>) {
        addToBooksR(books as NSSet)
    }

    public func remove(_ book: Book) {
        removeFromBooksR(book)
        if booksR?.count == 0 {
            managedObjectContext?.delete(self)
        }
    }

    public func remove(_ books: Set<Book>) {
        removeFromBooksR(books as NSSet)
        if booksR?.count == 0 {
            managedObjectContext?.delete(self)
        }
    }
    
    public override var description: String {
        let roleName = role?.name ?? "<unknown>"
        var personName = person?.name ?? "<unknown>"
        if let uuid = person?.uuid {
           personName += " (\(uuid))"
        }
        let bookList: String
        if books.count > 0 {
            bookList = " with " + books.map({ $0.nameAndId }).joined(separator: ",")
        } else {
            bookList = ""
        }
        
        return "<Relationship: \(roleName) for \(personName)\(bookList)>"
    }
    
    /// Does this relationship include a book?
    /// - Parameter book: the book to test
    public func contains(book: Book) -> Bool {
        return books.contains(book)
    }
}
