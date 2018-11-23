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
        public let identifier: String
        public let isPerson: Bool
    }
    

    public let details = DetailSpec.standardDetails
    public var people = [Relationship]()
    
    public init() {
        
    }
    
    public var rows: Int {
        return details.count + people.count
    }
    
    public func info(for row: Int) -> RowInfo {
        let peopleCount = people.count
        let isPerson = row < peopleCount
        let viewID: String
        if isPerson {
            viewID = DetailDataSource.personColumnID
        } else {
            if details[row - peopleCount].kind == .date  {
                viewID = DetailDataSource.dateColumnID
            } else {
                viewID = DetailDataSource.detailColumnID
            }
        }
        return RowInfo(identifier: viewID, isPerson: isPerson)
    }
    
    public func details(for row: Int) -> DetailSpec {
        return details[row - people.count]
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
