// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class PersonDetailProvider: DetailProvider {
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes"),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind),
                ])
        }
        
        return details
    }
    
    struct SortedRole {
        let role: Role
        let books: [Book]
    }
    
    var sortedRoles = [SortedRole]()
    
    public override var sectionCount: Int {
        return sortedRoles.count + super.sectionCount
    }
    
    public override func sectionTitle(for section: Int) -> String {
        if section == 0 {
            return super.sectionTitle(for: section)
        } else if let role = sortedRoles[section - 1].role.name {
            return "Role.title".localized(with: ["role" : role])
        } else {
            return ""
        }
    }
    
    public override func itemCount(for section: Int) -> Int {
        if section == 0 {
            return super.itemCount(for: section)
        } else {
            return sortedRoles[section - 1].books.count
        }
    }
    
    public override func info(section: Int, row: Int) -> DetailItem {
        if section == 0 {
            return super.info(section: section, row: row)
        } else {
            let books = sortedRoles[section - 1].books
            let info = PersonBookDetailItem(book: books[row], absolute: row, index: row, source: self)
            return info
        }
    }
    
    public override func filter(for selection: [ModelObject], editing: Bool, combining: Bool, context: DetailContext) {
        let template = PersonDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: false, context: context)
        if let person = selection.first as? Person, let relationships = person.relationships?.sortedArray(using: context.relationshipSorting) as? [Relationship] {
            sortedRoles.removeAll()
            for relationship in relationships {
                if let role = relationship.role,
                    let books = relationship.books?.sortedArray(using: context.bookSorting) as? [Book] {
                    sortedRoles.append(SortedRole(role: role, books: books))
                }
            }
        }
        
        if combining {
            combineItems()
        }
        
    }
}
