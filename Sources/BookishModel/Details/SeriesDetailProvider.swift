// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SeriesDetailProvider: DetailProvider {
    var sortedEntries = [SeriesEntry]()
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes", viewAs: DetailSpec.paragraphKind),
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

    override var sectionCount: Int {
        return 2
    }
    
    public override func sectionTitle(for section: Int) -> String {
        if section == 1 {
            return "Series.section".localized
        } else {
            return super.sectionTitle(for: section)
        }
    }
    
    public override func itemCount(for section: Int) -> Int {
        if section == 0 {
            return super.itemCount(for: section)
        } else {
            return sortedEntries.count
        }
    }
    
    public override func info(section: Int, row: Int) -> DetailItem {
        if section == 0 {
            return super.info(section: section, row: row)
        } else {
            let entry = sortedEntries[row]
            let info = SeriesEntryDetailItem(entry: entry, absolute: row, index: row, source: self)
            return info
        }
    }
    
    override func filter(for selection: Selection<ModelObject>, editing: Bool, combining: Bool, context: DetailContext) {
        if let series = selection.objects as? [Series] {
            let collectedTags = MultipleValues.extract(from: series) { series -> Set<Tag>? in
                return series.tags as? Set<Tag>
            }
            tags = collectedTags.common
        }

        // TODO: handle multiple selection properly?
        if let series = selection.objects.first as? Series, let sort = context.entitySorting["SeriesEntry"], let entries = series.entries?.sortedArray(using: sort) as? [SeriesEntry] {
            sortedEntries.removeAll()
            sortedEntries.append(contentsOf: entries)
        }

        let template = SeriesDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

