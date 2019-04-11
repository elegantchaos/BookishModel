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
            DetailSpec(binding: "items"),
            DetailSpec(binding: "added", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "modified", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "importDate", viewAs: DetailSpec.timeKind, editAs: DetailSpec.hiddenKind),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind),
                DetailSpec(binding: "log", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "imageURL", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "source", viewAs: DetailSpec.textKind, isDebug: true),
                ])
        }
        
        return details
    }

    override func buildItems() {
        super.buildItems()

        var row = items.count
        for index in 0 ..< sortedEntries.count {
            let entry = sortedEntries[index]
            let info = SeriesEntryDetailItem(entry: entry, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, combining: Bool, context: DetailContext) {
        
        if let series = selection.first as? Series, let sort = context.entitySorting["SeriesEntry"], let entries = series.entries?.sortedArray(using: sort) as? [SeriesEntry] {
            sortedEntries.removeAll()
            sortedEntries.append(contentsOf: entries)
        }

        let template = SeriesDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

