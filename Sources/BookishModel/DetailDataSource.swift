// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class DetailDataSource {
    static let headingColumnID = "heading"
    static let detailColumnID = "detail"
    static let personColumnID = "person"
    static let dateColumnID = "date"

    public struct RowInfo {
        public let kind: DetailSpec.Kind
        public let isPerson: Bool
    }
    

    private var details: [DetailSpec] = []
    private let template = DetailSpec.standardDetails
    private var people = [Relationship]()
    
    public init() {
        
    }
    
    public var rows: Int {
        return details.count + people.count
    }
    
    public func info(for row: Int, editing: Bool) -> (DetailSpec.Kind, Bool) {
        let peopleCount = people.count
        let isPerson = row < peopleCount
        var kind: DetailSpec.Kind
        if isPerson {
            kind = editing ? .editablePerson : .person
        } else {
            let spec = details[row - peopleCount]
            kind = editing ? spec.editableKind : spec.kind
        }
        return (kind, isPerson)
    }
    
    public func details(for row: Int) -> DetailSpec {
        return details[row - people.count]
    }
    
    public func filter(for selection: [Book], editing: Bool) {
        let (_, common) = people(in: selection)
        people = common.sorted(by: { ($0.person?.name ?? "") < ($1.person?.name ?? "") })
        if editing {
            details = template
        } else {
            var details = [DetailSpec]()
            for detail in template {
                var includeDetail = false
                for item in selection {
                    if item.value(forKey: detail.binding) != nil {
                        includeDetail = true
                        break
                    }
                }
                if includeDetail {
                    details.append(detail)
                }
            }
            self.details = details
        }
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
    
    
    public func person(for row: Int) -> Relationship {
        return people[row]
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
