// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class DetailDataSource {
    static let seriesHeading = "Series"
    static let publisherHeading = "Publisher"
    
    static let headingColumnID = "heading"
    static let controlColumnID = "control"

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
        
        public func viewID(for column: String) -> String {
            switch column {
                case headingColumnID:
                    return kind == .editablePerson ? "role" : headingColumnID
                case controlColumnID:
                    return controlColumnID
                default:
                    return kind.rawValue
            }
        }
    }
    
    private var editing: Bool = false
    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var people = [Relationship]()
    private var publishers = [Publisher]()
    private var series = [Entry]()
    private var items = [RowInfo]()
    
    public init() {
        
    }
    
    public var rows: Int {
        return items.count
//        let publisherCount = publishers.count
//        var count = details.count + people.count + publisherCount + series.count
//
//        if editing {
//            count += 2 // extra placeholders for people and series
//            if publisherCount == 0 {
//                count += 1 // extra placeholder for publisher only if we don't already have one
//            }
//        }
//
//        return count
    }
    
    public func info(for row: Int) -> RowInfo {
        return items[row]
//        var index = row
//        var info = matchPersonRow(row, index: &index)
//
//        if info == nil {
//            info = matchPublisherRow(row, index: &index)
//        }
//
//        if info == nil {
//            info = matchSeriesRow(row, index: &index)
//        }
//
//        if info == nil {
//            let spec = details[index]
//            info = RowInfo(kind: editing ? spec.editableKind : spec.kind, category: .detail, absolute: row, index: index, placeholder: false)
//        }
//
//        print("\(row) \(info!.kind) \(info!.category) \(info!.index)")
//        return info!
    }
    
//    private func matchPersonRow(_ row: Int, index: inout Int) -> RowInfo? {
//        let count = people.count
//        if row < count {
//            return RowInfo(kind: editing ? .editablePerson : .person, category: .person, absolute: row, index: index, placeholder: false)
//        }
//
//        index -= count
//
//        if editing {
//            if index == count {
//                return RowInfo(kind: .person, category: .person, absolute: row, index: index, placeholder: true)
//            }
//            index -= 1
//        }
//
//        return nil
//    }
//
//    private func matchPublisherRow(_ row: Int, index: inout Int) -> RowInfo? {
//        let count = publishers.count
//        if index < count {
//            return RowInfo(kind: .publisher, category: .publisher, absolute: row, index: index, placeholder: false)
//        }
//
//        index -= count
//
//        if editing && (count == 0) {
//            if index == 0 {
//                return RowInfo(kind: .publisher, category: .publisher, absolute: row, index: index, placeholder: true)
//            }
//            index -= 1
//        }
//
//        return nil
//    }
//
//    private func matchSeriesRow(_ row: Int, index: inout Int) -> RowInfo? {
//        let count = series.count
//        if index < count {
//            return RowInfo(kind: .series, category: .series, absolute: row, index: index, placeholder: false)
//        }
//
//        index -= count
//
//        if editing {
//            if index == count {
//                return RowInfo(kind: .series, category: .series, absolute: row, index: index, placeholder: true)
//            }
//            index -= 1
//        }
//
//        return nil
//    }

    func buildItems() {
        var row = 0
        var items = [RowInfo]()
        let peopleCount = people.count
        for index in 0 ..< peopleCount {
            let info = RowInfo(kind: editing ? .editablePerson : .person, category: .person, absolute: row, index: index, placeholder: false)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = RowInfo(kind: .editablePerson, category: .person, absolute: row, index: peopleCount, placeholder: true)
            items.append(info)
            row += 1
        }
        
        let publisherCount = publishers.count
        for index in 0 ..< publisherCount {
            let info = RowInfo(kind: .publisher, category: .publisher, absolute: row, index: index, placeholder: false)
            items.append(info)
            row += 1
        }
        
        if editing && publisherCount == 0 {
            let info = RowInfo(kind: .publisher, category: .publisher, absolute: row, index: 0, placeholder: true)
            items.append(info)
            row += 1
        }
        
        let seriesCount = series.count
        for index in 0 ..< seriesCount {
            let info = RowInfo(kind: .series, category: .series, absolute: row, index: index, placeholder: false)
            items.append(info)
            row += 1
        }
        
        if editing {
            let info = RowInfo(kind: .series, category: .series, absolute: row, index: seriesCount, placeholder: true)
            items.append(info)
            row += 1
        }
        
        let detailCount = details.count
        for index in 0 ..< detailCount {
            let spec = details[index]
            let info = RowInfo(kind: editing ? spec.editableKind : spec.kind, category: .detail, absolute: row, index: index, placeholder: false)
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
        
        let (_, common) = people(in: selection)
        people = common.sorted(by: { ($0.person?.name ?? "") < ($1.person?.name ?? "") })
        publishers = publishers(in: selection).sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        series = series(in: selection).sorted(by: {($0.series?.name ?? "") < ($1.series?.name ?? "")})
        details = filteredDetails

        buildItems()
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
            return row.placeholder ? "Person" : person(for: row).role?.name ?? "<unknown role>"
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
