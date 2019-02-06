// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class DetailDataSource {
    static let seriesHeading = "Series"
    static let publisherHeading = "Publisher"
    static let personHeading = "Person"
    
    static let headingColumnID = "heading"
    static let controlColumnID = "control"
    static let roleColumnID = "role"
    
    public enum Category {
        case detail
        case person
        case publisher
        case series
    }

    public struct RowInfo {
        public let kind: DetailSpec.Kind
        public let category: Category
        public let absolute: Int
        public let index: Int
        public let placeholder: Bool
        public let source: DetailDataSource // TODO: should be weak?
        
        public func viewID(for column: String) -> String {
            switch column {
                case headingColumnID:
                    return kind == .person ? roleColumnID : headingColumnID
                
                case controlColumnID:
                    return controlColumnID
                
                default:
                    return kind.rawValue
            }
        }
    }
    
    public private(set) var editing: Bool = false
    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var relationships = [Relationship]()
    private var publishers = [Publisher]()
    private var series = [Series]()
    private var items = [RowInfo]()
    
    public init() {
        
    }
    
    public var rows: Int {
        return items.count
    }
    
    public func info(for row: Int) -> RowInfo {
        return items[row]
    }

    func buildItems() {
        var row = 0
        var items = [RowInfo]()
        let peopleCount = relationships.count
        for index in 0 ..< peopleCount {
            let info = RowInfo(kind: .person, category: .person, absolute: row, index: index, placeholder: false, source: self)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = RowInfo(kind: .person, category: .person, absolute: row, index: peopleCount, placeholder: true, source: self)
            items.append(info)
            row += 1
        }
        
        let publisherCount = publishers.count
        for index in 0 ..< publisherCount {
            let info = RowInfo(kind: .publisher, category: .publisher, absolute: row, index: index, placeholder: false, source: self)
            items.append(info)
            row += 1
        }
        
        if editing && publisherCount == 0 {
            let info = RowInfo(kind: .publisher, category: .publisher, absolute: row, index: 0, placeholder: true, source: self)
            items.append(info)
            row += 1
        }
        
        let seriesCount = series.count
        for index in 0 ..< seriesCount {
            let info = RowInfo(kind: .series, category: .series, absolute: row, index: index, placeholder: false, source: self)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = RowInfo(kind: .series, category: .series, absolute: row, index: seriesCount, placeholder: true, source: self)
            items.append(info)
            row += 1
        }
        
        let detailCount = details.count
        for index in 0 ..< detailCount {
            let spec = details[index]
            let info = RowInfo(kind: editing ? spec.editableKind : spec.kind, category: .detail, absolute: row, index: index, placeholder: false, source: self)
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
            if kind != .hidden {
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
    

    public func heading(for row: RowInfo) -> String {
        let heading: String
        switch row.category {
        case .detail:
            heading = details(for: row).label
        case .person:
            heading = row.placeholder ? DetailDataSource.personHeading : relationship(for: row).role?.name ?? "<unknown role>"
        case .publisher:
            heading = DetailDataSource.publisherHeading
        case .series:
            heading = DetailDataSource.seriesHeading
        }
        
        return heading.lowercased()
    }
    
    public func relationship(for row: RowInfo) -> Relationship {
        assert(row.category == .person)
        return relationships[row.index]
    }

    public func publisher(for row: RowInfo) -> Publisher {
        assert(row.category == .publisher)
        return publishers[row.index]
    }

    public func series(for row: RowInfo) -> Series {
        assert(row.category == .series)
        return series[row.index]
    }

    public func details(for row: RowInfo) -> DetailSpec {
        assert(row.category == .detail)
        return details[row.index]
    }
    
    public func insert(relationship: Relationship) -> Int {
        let index = relationships.count
        relationships.append(relationship)
        buildItems()
        return items.first(where:{ $0.kind == .person && $0.index == index })!.absolute
    }
    
    public func remove(relationship: Relationship) -> Int? {
        guard let index = relationships.firstIndex(of: relationship), let item = items.first(where:{ $0.kind == .person && $0.index == index }) else { return nil }
        relationships.remove(at: index)
        return item.absolute
    }

    public func update(relationship: Relationship, with: Relationship) -> Int? {
        guard let index = relationships.firstIndex(of: relationship), let item = items.first(where:{ $0.kind == .person && $0.index == index }) else { return nil }
        relationships[index] = with
        return item.absolute
    }
    
    public func insert(series seriesToInsert: Series) -> Int {
        let index = series.count
        series.append(seriesToInsert)
        buildItems()
        return items.last(where:{ $0.kind == .series && $0.index == index })!.absolute
    }
    
    public func remove(series seriesToRemove: Series) -> Int? {
        guard let index = series.firstIndex(of: seriesToRemove), let item = items.first(where:{ $0.kind == .series && $0.index == index }) else { return nil }
        series.remove(at: index)
        return item.absolute
    }

    public func insert(publisher: Publisher) -> Int {
        publishers = [publisher] // currently we cap the number of publishers at 1
        buildItems()
        return items.first(where:{ $0.kind == .publisher })!.absolute
    }

    public func remove(publisher: Publisher) -> Int? {
        guard let index = publishers.firstIndex(of: publisher), let item = items.first(where:{ $0.kind == .publisher && $0.index == index }) else { return nil }
        publishers.remove(at: index)
        return item.absolute
    }
}
