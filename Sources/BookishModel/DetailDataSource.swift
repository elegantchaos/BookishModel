// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class DetailDataSource {
    static let seriesHeading = "Series"
    static let publisherHeading = "Publisher"

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
    }
    

    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var people = [Relationship]()
    private var publishers = [Publisher]()
    private var series = [Entry]()

    public init() {
        
    }
    
    public var rows: Int {
        return details.count + people.count + publishers.count + series.count
    }
    
    public func info(for row: Int, editing: Bool) -> RowInfo {
        
        let category: Category
        let index: Int
        let peopleCount = people.count
        var kind: DetailSpec.Kind
        
        if row < peopleCount {
            category = .person
            kind = editing ? .editablePerson : .person
            index = row
        } else {
            let publisherRow = row - peopleCount
            let publisherCount = publishers.count
            let isPublisher = publisherRow < publisherCount
            if isPublisher {
                category = .publisher
                kind = .publisher
                index = publisherRow
            } else {
                let seriesRow = publisherRow - publisherCount
                let seriesCount = series.count
                let isSeries = seriesRow < seriesCount
                if isSeries {
                    category = .series
                    kind = .series
                    index = seriesRow
                } else {
                    index = seriesRow - seriesCount
                    let spec = details[index]
                    kind = editing ? spec.editableKind : spec.kind
                    category = .detail
                }
            }
        }
        
        return RowInfo(kind: kind, category: category, absolute: row, index: index)
    }
    
    public func filter(for selection: [Book], editing: Bool) {
        let (_, common) = people(in: selection)
        people = common.sorted(by: { ($0.person?.name ?? "") < ($1.person?.name ?? "") })
        publishers = publishers(in: selection).sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        series = series(in: selection).sorted(by: {($0.series?.name ?? "") < ($1.series?.name ?? "")})
        
        var details = [DetailSpec]()
        for detail in template {
            var includeDetail = false
            let kind = editing ? detail.editableKind : detail.kind
            if kind != .hidden {
                for item in selection {
                    if let value = item.value(forKey: detail.binding) as? String {
                        includeDetail = !value.isEmpty
                        break
                    }
                }
            }

            if includeDetail {
                details.append(detail)
            }
        }
        self.details = details
    }
    
    public func people(in selection: [Book]) -> (Set<Relationship>, Set<Relationship>) {
        var all = Set<Relationship>()
        var common = Set<Relationship>()
        for book in selection {
            if let people = book.relationships as? Set<Relationship> {
                if all.count == 0 {
                    common.formUnion(people)
                } else {
                    common.formIntersection(people)
                }
                all.formUnion(people)
            }
        }
        return (all, common)
    }

    public func publishers(in selection: [Book]) -> Set<Publisher> {
        var all = Set<Publisher>()
        for book in selection {
            if let publisher = book.publisher {
                all.insert(publisher)
            }
        }
        return all
    }

    public func series(in selection: [Book]) -> Set<Entry> {
        var all = Set<Entry>()
        for book in selection {
            if let entry = book.series {
                all.insert(entry)
            }
        }
        return all
    }
    
    public func heading(for row: RowInfo) -> String {
        switch row.category {
        case .detail:
            return details(for: row).label
        case .person:
            return person(for: row).role?.name ?? "<unknown role>"
        case .publisher:
            return DetailDataSource.publisherHeading
        case .series:
            return DetailDataSource.seriesHeading
        }
    }
    
    public func person(for row: RowInfo) -> Relationship {
        assert(row.category == .person)
        return people[row.index]
    }

    public func publisher(for row: RowInfo) -> Publisher {
        assert(row.category == .publisher)
        return publishers[row.index]
    }

    public func series(for row: RowInfo) -> Entry {
        assert(row.category == .series)
        return series[row.index]
    }

    public func details(for row: RowInfo) -> DetailSpec {
        assert(row.category == .detail)
        return details[row.index]
    }
    
    public func insert(relationship: Relationship) -> Int {
        let index = people.count
        people.append(relationship)
        return index
    }
    
    public func remove(relationship: Relationship) -> Int? {
        guard let row = people.firstIndex(of: relationship) else { return nil }
        people.remove(at: row)
        return row
    }
}
