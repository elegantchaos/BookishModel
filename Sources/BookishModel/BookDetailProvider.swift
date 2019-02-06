// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Book: DetailOwner {
    public func getProvider() -> DetailProvider {
        return BookDetailProvider()
    }
}

public class PublisherDetailItem: DetailItem {
    public let publisher: Publisher?
    
    public init(publisher: Publisher? = nil, absolute: Int, index: Int, source: BookDetailProvider? = nil) {
        self.publisher = publisher
        super.init(kind: "publisher", absolute: absolute, index: index, placeholder: publisher == nil, source: source)
    }
    
    public override var heading: String {
        return "Publisher"
    }
}

public class SeriesDetailItem: DetailItem {
    public let series: Series?
    
    public init(series: Series? = nil, absolute: Int, index: Int, source: BookDetailProvider? = nil) {
        self.series = series
        super.init(kind: "series", absolute: absolute, index: index, placeholder: series == nil, source: source)
    }

    public override var heading: String {
        return "Series"
    }
}

public class PersonDetailItem: DetailItem {
    public let relationship: Relationship?
    
    public init(relationship: Relationship? = nil, absolute: Int, index: Int, source: BookDetailProvider? = nil) {
        self.relationship = relationship
        super.init(kind: "person", absolute: absolute, index: index, placeholder: relationship == nil, source: source)
    }

    public override var heading: String {
        return placeholder ? "Person" : relationship?.role?.name ?? super.heading
    }
    
    override public func viewID(for column: String) -> String { // TODO: move out of model?
        switch column {
        case headingColumnID:
            return roleColumnID
            
        default:
            return super.viewID(for: column)
        }
    }

}

public class BookDetailProvider {
    public private(set) var editing: Bool = false
    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var relationships = [Relationship]()
    private var publishers = [Publisher]()
    private var series = [Series]()
    private var items = [DetailItem]()
    
    public init() {
        
    }
    
    public var rows: Int {
        return items.count
    }
    
    public func info(for row: Int) -> DetailItem {
        return items[row]
    }
    
    func buildItems() {
        var row = 0
        var items = [DetailItem]()
        let peopleCount = relationships.count
        for index in 0 ..< peopleCount {
            let info = PersonDetailItem(relationship: relationships[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = PersonDetailItem(absolute: row, index: peopleCount, source: self)
            items.append(info)
            row += 1
        }
        
        let publisherCount = publishers.count
        for index in 0 ..< publisherCount {
            let info = PublisherDetailItem(publisher: publishers[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if editing && publisherCount == 0 {
            let info = PublisherDetailItem(absolute: row, index: 0, source: self)
            items.append(info)
            row += 1
        }
        
        let seriesCount = series.count
        for index in 0 ..< seriesCount {
            let info = SeriesDetailItem(series: series[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = SeriesDetailItem(absolute: row, index: seriesCount, source: self)
            items.append(info)
            row += 1
        }
        
        let detailCount = details.count
        for index in 0 ..< detailCount {
            let spec = details[index]
            let info = SimpleDetailItem(kind: editing ? spec.editableKind : spec.kind, absolute: row, index: index, placeholder: false, source: self)
            items.append(info)
            row += 1
        }
        
        self.items = items
    }
    
    public func filter(for selection: [Book], editing: Bool) {
        self.editing = editing
        
        var filteredDetails = [DetailSpec]()
        for detail in template {
            var includeDetail = false
            let kind = editing ? detail.editableKind : detail.kind
            if kind != DetailSpec.hiddenKind {
                if editing {
                    includeDetail = true
                } else {
                    for item in selection {
                        if let value = item.value(forKey: detail.binding) as? String {
                            includeDetail = !value.isEmpty
                            break
                        }
                    }
                }
            }
            
            if includeDetail {
                filteredDetails.append(detail)
            }
        }
        
        let collectedRelationships = MultipleValues.extract(from: selection) { book -> Set<Relationship>? in
            return book.relationships as? Set<Relationship>
        }
        
        let collectedPublishers = MultipleValues.extract(from: selection) { book -> Set<Publisher>? in
            return book.publisher == nil ? nil : Set<Publisher>([book.publisher!])
        }
        
        let collectedSeries = MultipleValues.extract(from: selection) { book -> Set<Series>? in
            if let entries = book.entries as? Set<SeriesEntry> {
                let series = entries.map { $0.series } as! [Series]
                return Set<Series>(series)
            }
            
            return nil
        }
        
        relationships = collectedRelationships.common.sorted(by: { ($0.person?.name ?? "") < ($1.person?.name ?? "") })
        publishers = collectedPublishers.common.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        series = collectedSeries.common.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        details = filteredDetails
        
        buildItems()
    }
    
    
//    public func heading(for row: DetailItem) -> String {
//        let heading: String
//        switch row.category {
//        case .detail:
//            heading = details(for: row).label
//        case .person:
//            heading = row.placeholder ? BookDetailProvider.personHeading : relationship(for: row).role?.name ?? "<unknown role>"
//        case .publisher:
//            heading =
//        case .series:
//            heading = BookDetailProvider.seriesHeading
//        }
//
//        return heading.lowercased()
//    }
    
//    public func relationship(for row: DetailItem) -> Relationship {
//        assert(row is PersonDetailItem)
//        return relationships[row.index]
//    }
    
    public func details(for row: DetailItem) -> DetailSpec {
        return details[row.index]
    }
    
    public func insert(relationship: Relationship) -> Int {
        let index = relationships.count
        relationships.append(relationship)
        buildItems()
        return items.first(where:{ $0 is PersonDetailItem && $0.index == index })!.absolute
    }
    
    public func remove(relationship: Relationship) -> Int? {
        guard let index = relationships.firstIndex(of: relationship), let item = items.first(where:{ $0 is PersonDetailItem && $0.index == index }) else { return nil }
        relationships.remove(at: index)
        return item.absolute
    }
    
    public func update(relationship: Relationship, with: Relationship) -> Int? {
        guard let index = relationships.firstIndex(of: relationship), let item = items.first(where:{ $0 is PersonDetailItem && $0.index == index }) else { return nil }
        relationships[index] = with
        return item.absolute
    }
    
    public func insert(series seriesToInsert: Series) -> Int {
        let index = series.count
        series.append(seriesToInsert)
        buildItems()
        return items.last(where:{ $0 is SeriesDetailItem && $0.index == index })!.absolute
    }
    
    public func remove(series seriesToRemove: Series) -> Int? {
        guard let index = series.firstIndex(of: seriesToRemove), let item = items.first(where:{ $0 is SeriesDetailItem && $0.index == index }) else { return nil }
        series.remove(at: index)
        return item.absolute
    }
    
    public func insert(publisher: Publisher) -> Int {
        publishers = [publisher] // currently we cap the number of publishers at 1
        buildItems()
        return items.first(where:{ $0 is PublisherDetailItem })!.absolute
    }
    
    public func remove(publisher: Publisher) -> Int? {
        guard let index = publishers.firstIndex(of: publisher), let item = items.first(where:{ $0 is PublisherDetailItem && $0.index == index }) else { return nil }
        publishers.remove(at: index)
        return item.absolute
    }
}
