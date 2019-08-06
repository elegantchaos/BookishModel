// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class BookDetailProvider: DetailProvider {
    private var relationships = [Relationship]()
    private var publishers = [Publisher]()
    private var entries = [SeriesEntry]()
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "subtitle", viewAs: DetailSpec.hiddenKind, editAs: DetailSpec.textKind),
            DetailSpec(binding: "notes", viewAs: DetailSpec.paragraphKind),
            DetailSpec(binding: "format"),
            DetailSpec(binding: "identifier", viewAs: DetailSpec.textKind, editAs: DetailSpec.hiddenKind),
            DetailSpec(binding: "asin", viewAs: DetailSpec.hiddenKind, editAs: DetailSpec.textKind),
            DetailSpec(binding: "isbn", viewAs: DetailSpec.hiddenKind, editAs: DetailSpec.textKind),
            DetailSpec(binding: "classification"),
            DetailSpec(binding: "owner"),
            DetailSpec(binding: "published", viewAs: DetailSpec.dateKind, editAs: DetailSpec.editableDateKind),
            DetailSpec(binding: "read", viewAs: DetailSpec.dateKind, editAs: DetailSpec.editableDateKind),
            DetailSpec(binding: "added", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "modified", viewAs: DetailSpec.timeKind),
            DetailSpec(binding: "importDate", viewAs: DetailSpec.timeKind, editAs: DetailSpec.hiddenKind),
            DetailSpec(binding: "dimensions", viewAs: DetailSpec.dimensionsKind),
            DetailSpec(binding: "pages", viewAs: DetailSpec.numberKind),
            DetailSpec(binding: "weight", viewAs: DetailSpec.numberKind),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "log", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "imageURL", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "source", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "importRaw", viewAs: DetailSpec.hiddenKind, editAs: DetailSpec.textKind, isDebug: true),
                ])
        }
        
        return details
    }

    override public var visibleColumns: [String] {
        return isEditing ? DetailProvider.EditingColumns : DetailProvider.LabelledColumns
    }

    override public func filter(for selection: ModelSelection, editing: Bool, combining: Bool, context: DetailContext) {
        let template = BookDetailProvider.standardDetails(showDebug: context.showDebug)
        if let books = selection.objects as? [Book] {
            let collectedRelationships = MultipleValues.extract(from: books) { book -> Set<Relationship>? in
                return book.relationships as? Set<Relationship>
            }
            
            let collectedPublishers = MultipleValues.extract(from: books) { book -> Set<Publisher>? in
                return book.publisher == nil ? nil : Set<Publisher>([book.publisher!])
            }
            
            let collectedSeries = MultipleValues.extract(from: books) { book -> Set<SeriesEntry>? in
                return book.entries as? Set<SeriesEntry>
            }
            
            let collectedTags = MultipleValues.extract(from: books) { book -> Set<Tag>? in
                return book.tags as? Set<Tag>
            }
            
            relationships = collectedRelationships.common.sorted(by: { ($0.person?.name ?? "") < ($1.person?.name ?? "") })
            publishers = collectedPublishers.common.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            entries = collectedSeries.common.sorted(by: {($0.series?.name ?? "") < ($1.series?.name ?? "")})
            tags = collectedTags.common
        }
        
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
    
    override func buildItems() {
        var row = items.count

        let peopleCount = relationships.count
        for index in 0 ..< peopleCount {
            let info = RelationshipDetailItem(relationship: relationships[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if isEditing {
            let info = RelationshipDetailItem(absolute: row, index: peopleCount, source: self)
            items.append(info)
            row += 1
        }
        
        let publisherCount = publishers.count
        for index in 0 ..< publisherCount {
            let info = PublisherDetailItem(publisher: publishers[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if isEditing && publisherCount == 0 {
            let info = PublisherDetailItem(absolute: row, index: 0, source: self)
            items.append(info)
            row += 1
        }
        
        let entriesCount = entries.count
        for index in 0 ..< entriesCount {
            let info = SeriesDetailItem(entry: entries[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if isEditing {
            let info = SeriesDetailItem(absolute: row, index: entriesCount, source: self)
            items.append(info)
            row += 1
        }
        
        super.buildItems()
    }
    
    public override func inserted(details: [ModelObject]) -> IndexSet {
        var changed = false
        for detail in details {
            switch detail {
            case let r as Relationship:
                relationships.append(r)
                changed = true
                
            case let s as SeriesEntry:
                entries.append(s)
                changed = true
                
            case let p as Publisher:
                publishers = [p] // currently we cap the number of publishers at 1
                changed = true
                
            default:
                break
            }
        }
        
        var changes = IndexSet()
        if changed {
            rebuildItems()
            for detail in details {
                changes.insert(items.first(where:{ $0.object == detail })!.absolute)
            }
        }
        return changes
    }
    
    public override func removed(details: [ModelObject]) -> IndexSet {
        var changes = IndexSet()
        for detail in details {
            if let item = items.first(where: { $0.matches(object: detail) } ) {
                changes.insert(item.absolute)
                switch detail {
                case let r as Relationship:
                    if let index = relationships.firstIndex(of: r) {
                        relationships.remove(at: index)
                    }

                case let s as Series:
                    if let index = entries.firstIndex(where: {$0.series == s}) {
                        entries.remove(at: index)
                    }

                case let e as SeriesEntry:
                    if let index = entries.firstIndex(of: e) {
                        entries.remove(at: index)
                    }
                    
                case let p as Publisher:
                    if let index = publishers.firstIndex(of: p) {
                        publishers.remove(at: index)
                    }
                    
                default:
                    break
                }
            }
        }
        
        if changes.count > 0 {
            rebuildItems()
        }
        
        return changes
    }
    
    public override func updated(details: [ModelObject], with: [ModelObject]) -> IndexSet {
        assert(details.count == with.count)

        var changes = IndexSet()
        for n in 0 ..< details.count {
            let detail = details[n]
            if let item = items.first(where: { $0.object == detail } ) {
                changes.insert(item.absolute)
                let newDetail = with[n]
                switch newDetail {
                case let r as Relationship:
                    relationships[item.index] = r
                    
                case let e as SeriesEntry:
                    entries[item.index] = e
                    
                case let p as Publisher:
                    publishers = [p]
                    
                default:
                    break
                }
            }
        }
        
        if changes.count > 0 {
            rebuildItems()
        }

        return changes
    }
}


