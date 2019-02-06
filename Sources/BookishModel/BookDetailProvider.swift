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

public class BookDetailProvider: BasicDetailProvider {
    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var relationships = [Relationship]()
    private var publishers = [Publisher]()
    private var series = [Series]()
    private var items = [DetailItem]()
    
    func buildItems() {
        var row = 0
        var items = [DetailItem]()
        let peopleCount = relationships.count
        for index in 0 ..< peopleCount {
            let info = PersonDetailItem(relationship: relationships[index], absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        if isEditing {
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
        
        if isEditing && publisherCount == 0 {
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
        
        if isEditing {
            let info = SeriesDetailItem(absolute: row, index: seriesCount, source: self)
            items.append(info)
            row += 1
        }
        
        let detailCount = details.count
        for index in 0 ..< detailCount {
            let spec = details[index]
            let info = SimpleDetailItem(spec: spec, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
        
        self.items = items
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


extension BookDetailProvider: DetailProvider {
    public func info(section: Int, row: Int) -> DetailItem {
        return items[row]
    }
    
    public func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let books = selection as? [Book] {
            self.isEditing = editing
            
            var filteredDetails = [DetailSpec]()
            for detail in template {
                var includeDetail = false
                let kind = editing ? detail.editableKind : detail.kind
                if kind != DetailSpec.hiddenKind {
                    if editing {
                        includeDetail = true
                    } else {
                        for item in books {
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
            
            let collectedRelationships = MultipleValues.extract(from: books) { book -> Set<Relationship>? in
                return book.relationships as? Set<Relationship>
            }
            
            let collectedPublishers = MultipleValues.extract(from: books) { book -> Set<Publisher>? in
                return book.publisher == nil ? nil : Set<Publisher>([book.publisher!])
            }
            
            let collectedSeries = MultipleValues.extract(from: books) { book -> Set<Series>? in
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
    }
    
    public var sectionCount: Int {
        return 1
    }
    
    public func sectionTitle(for section: Int) -> String {
        return ""
    }
    
    public func itemCount(for section: Int) -> Int {
        return items.count
    }
    
    public var titleProperty: String? {
        return "name"
    }
    
    public var subtitleProperty: String? {
        return "subtitle"
    }
}

