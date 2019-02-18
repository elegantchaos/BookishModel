// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SeriesDetailProvider: DetailProvider {
    var sortedEntries = [SeriesEntry]()
    
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
        super.buildItems()

        var row = items.count
        for index in 0 ..< sortedEntries.count {
            let book = sortedEntries[index].book
            let info = PersonBookDetailItem(book: book, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, combining: Bool, context: DetailContext) {
        if let series = selection.first as? Series, let entries = series.entries?.sortedArray(using: context.entrySorting) as? [SeriesEntry] {
            sortedEntries.removeAll()
            sortedEntries.append(contentsOf: entries)
        }

        let template = SeriesDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

