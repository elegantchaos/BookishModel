// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

extension Person: DetailOwner {
    public func getProvider() -> DetailProvider {
        return PersonDetailProvider()
    }
}

public class PersonBookDetailItem: DetailItem {
    public let book: Book?
    
    public init(book: Book?, absolute: Int, index: Int, source: DetailProvider) {
        self.book = book
        super.init(kind: "book", absolute: absolute, index: index, placeholder: book == nil, source: source)
    }
}

class PersonDetailProvider: DetailProvider {
    
    struct SortedRole {
        let role: Role
        let books: [Book]
    }
    
    var sortedRoles = [SortedRole]()
    
    override var sectionCount: Int {
        return sortedRoles.count + super.sectionCount
    }
    
    override func sectionTitle(for section: Int) -> String {
        if section == 0 {
            return super.sectionTitle(for: section)
        } else {
            return sortedRoles[section - 1].role.name ?? ""
        }
    }
    
    override func itemCount(for section: Int) -> Int {
        if section == 0 {
            return super.itemCount(for: section)
        } else {
            return sortedRoles[section - 1].books.count
        }
    }
    
    override func info(section: Int, row: Int) -> DetailItem {
        if section == 0 {
            return super.info(section: section, row: row)
        } else {
            let books = sortedRoles[section - 1].books
            let info = PersonBookDetailItem(book: books[row], absolute: row, index: row, source: self)
            return info
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        super.filter(for: selection, editing: editing, context: context)
        if let person = selection.first as? Person, let relationships = person.relationships?.sortedArray(using: context.relationshipSorting) as? [Relationship] {
            sortedRoles.removeAll()
            for relationship in relationships {
                if let role = relationship.role,
                    let books = relationship.books?.sortedArray(using: context.bookSorting) as? [Book] {
                    sortedRoles.append(SortedRole(role: role, books: books))
                }
            }
        }
    }
}
