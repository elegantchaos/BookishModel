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
    
    var titleProperty: String? {
        return "name"
    }
    
    var subtitleProperty: String? {
        return nil
    }
    
    var sectionCount: Int {
        return 1
    }
    
    func sectionTitle(for section: Int) -> String {
        return ""
    }
    
    func itemCount(for section: Int) -> Int {
        return sortedBooks.count
    }
    
    func info(section: Int, row: Int) -> DetailItem {
        let book = sortedBooks[row]
        let info = PersonBookDetailItem(book: book, absolute: row, index: row, source: nil)
        return info
    }
    
    func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let series = selection.first as? Publisher, let books = series.books?.sortedArray(using: context.bookIndexSorting) as? [Book] {
            sortedBooks.removeAll()
            sortedBooks.append(contentsOf: books)
        }
    }
}

