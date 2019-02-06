// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Series: DetailOwner {
    public func getProvider() -> DetailProvider {
        return SeriesDetailProvider()
    }
}

class SeriesDetailProvider: DetailProvider {
    var sortedEntries = [SeriesEntry]()
    
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
        return sortedEntries.count
    }
    
    func info(section: Int, row: Int) -> DetailItem {
        let book = sortedEntries[row].book
        let info = PersonBookDetailItem(book: book, absolute: row, index: row, source: nil)
        return info
    }
    
    func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let series = selection.first as? Series, let entries = series.entries?.sortedArray(using: context.entrySorting) as? [SeriesEntry] {
            sortedEntries.removeAll()
            sortedEntries.append(contentsOf: entries)
        }
    }
}

