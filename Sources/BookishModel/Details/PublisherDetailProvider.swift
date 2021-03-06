// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class PublisherDetailProvider: DetailProvider {
    var sortedBooks = [Book]()

    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes", viewAs: DetailSpec.paragraphKind),
            DetailSpec(binding: "added", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "modified", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "importDate", viewAs: DetailSpec.timeKind, editAs: DetailSpec.hiddenKind),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind),
                DetailSpec(binding: "imageURL", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "source", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "log", viewAs: DetailSpec.paragraphKind, isDebug: true),
                ])
        }
        
        return details
    }

    override var sectionCount: Int {
        return 2
    }
    
    public override func sectionTitle(for section: Int) -> String {
        if section == 1 {
            return "Publisher.section".localized
        } else {
            return super.sectionTitle(for: section)
        }
    }

    public override func itemCount(for section: Int) -> Int {
        if section == 0 {
            return super.itemCount(for: section)
        } else {
            return sortedBooks.count
        }
    }
    
    public override func info(section: Int, row: Int) -> DetailItem {
        if section == 0 {
            return super.info(section: section, row: row)
        } else {
            let info = BookDetailItem(book: sortedBooks[row], mode: .publisher, absolute: row, index: row, source: self)
            return info
        }
    }
    
    override func filter(for selection: ModelSelection, editing: Bool, combining: Bool, session: ModelSession) {
        if let publishers = selection.objects as? [Publisher] {
            let collectedTags = MultipleValues.extract(from: publishers) { publisher -> Set<Tag>? in
                return publisher.tags
            }
            tags = collectedTags.common
        }

        // TODO: handle multiple selection properly
        if let publisher = selection.objects.first as? Publisher {
            let books = publisher.books(sortedBy: session.books.sorting)
            sortedBooks.removeAll()
            sortedBooks.append(contentsOf: books)
        }

        let template = PublisherDetailProvider.standardDetails(showDebug: session.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, session: session)
    }
}

