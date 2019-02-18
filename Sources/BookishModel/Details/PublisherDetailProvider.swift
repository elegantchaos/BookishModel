// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class PublisherDetailProvider: DetailProvider {
    var sortedBooks = [Book]()

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

    override func buildItems() {
        var row = items.count
        for index in 0 ..< sortedBooks.count {
            let book = sortedBooks[index]
            let info = BookDetailItem(book: book, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, combining: Bool, context: DetailContext) {
        if let series = selection.first as? Publisher, let books = series.books?.sortedArray(using: context.bookSorting) as? [Book] {
            sortedBooks.removeAll()
            sortedBooks.append(contentsOf: books)
        }

        let template = PublisherDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

