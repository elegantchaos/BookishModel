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
    
    public init(book: Book?, absolute: Int, index: Int, source: BookDetailProvider? = nil) {
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
    
    var titleProperty: String? {
        return "name"
    }
    
    var subtitleProperty: String? {
        return nil
    }
    
    var sectionCount: Int {
        return sortedRoles.count
    }
    
    func sectionTitle(for section: Int) -> String {
        return sortedRoles[section].role.name ?? ""
    }
    
    func itemCount(for section: Int) -> Int {
        return sortedRoles[section].books.count
    }
    
    func info(section: Int, row: Int) -> DetailItem {
        let books = sortedRoles[section].books
        let info = PersonBookDetailItem(book: books[row], absolute: row, index: row, source: nil)
        return info
    }
    
    func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let person = selection.first as? Person, let relationships = person.relationships?.sortedArray(using: context.relationshipSorting) as? [Relationship] {
            sortedRoles.removeAll()
            for relationship in relationships {
                if let role = relationship.role,
                    let books = relationship.books?.sortedArray(using: context.bookIndexSorting) as? [Book] {
                    sortedRoles.append(SortedRole(role: role, books: books))
                }
            }
        }
    }
    
    
}

//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let role = sortedRoles[indexPath.section]
//        let book = role.books[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "book") as! PersonBookRow // if we fail here, it's a coding error as all possible view types should have been registered
//        cell.setup(row: indexPath.row, book: book, role:role.role)
//        return cell
//    }
//
