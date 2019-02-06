// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Publisher: DetailOwner {
    public func getProvider() -> DetailProvider {
        return PublisherDetailProvider()
    }
}

class PublisherDetailProvider: DetailProvider {
    var sortedBooks = [Book]()

    override func buildItems() {
        var row = items.count
        for index in 0 ..< sortedBooks.count {
            let book = sortedBooks[index]
            let info = PersonBookDetailItem(book: book, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let series = selection.first as? Publisher, let books = series.books?.sortedArray(using: context.bookIndexSorting) as? [Book] {
            sortedBooks.removeAll()
            sortedBooks.append(contentsOf: books)
        }

        super.filter(for: selection, editing: editing, context: context)
    }
}

