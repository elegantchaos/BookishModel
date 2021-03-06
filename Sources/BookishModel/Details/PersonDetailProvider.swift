// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class PersonDetailProvider: DetailProvider {
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes", viewAs: DetailSpec.paragraphKind),
            DetailSpec(binding: "biography", viewAs: DetailSpec.paragraphKind),
            DetailSpec(binding: "born", viewAs: DetailSpec.dateKind, editAs: DetailSpec.editableDateKind),
            DetailSpec(binding: "died", viewAs: DetailSpec.dateKind, editAs: DetailSpec.editableDateKind),
            DetailSpec(binding: "added", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "modified", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "importDate", viewAs: DetailSpec.timeKind, editAs: DetailSpec.hiddenKind),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "imageURL", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "source", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "log", viewAs: DetailSpec.paragraphKind, isDebug: true),
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
            return "Role.section".localized(with: ["role" : role])
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
            let info = BookDetailItem(book: books[row], mode: .person, absolute: row, index: row, source: self)
            return info
        }
    }
    
    public override func filter(for selection: ModelSelection, editing: Bool, combining: Bool, session: ModelSession) {
        let template = PersonDetailProvider.standardDetails(showDebug: session.showDebug)
        if let people = selection.objects as? [Person] {
            let collectedTags = MultipleValues.extract(from: people) { person -> Set<Tag> in return person.tags }
            tags = collectedTags.common
        }

        super.filter(for: selection, template: template, editing: editing, combining: false, session: session)

        sortedRoles.removeAll()
        if let person = selection.objects.first as? Person {
            let relationships = person.relationships(sortedBy: session.people.sorting)
            for relationship in relationships {
                if let role = relationship.role {
                    let books = relationship.books(sortedBy: session.books.sorting)
                    sortedRoles.append(SortedRole(role: role, books: books))
                }
            }
        }
        
        if combining {
            combineItems()
        }
        
    }
    
}
