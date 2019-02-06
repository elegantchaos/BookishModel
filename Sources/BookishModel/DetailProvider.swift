// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public protocol DetailContext {
    var relationshipSorting: [NSSortDescriptor] { get }
    var bookIndexSorting: [NSSortDescriptor] { get }
    var entrySorting: [NSSortDescriptor] { get }
}

public protocol DetailOwner {
    func getProvider() -> DetailProvider
}

public protocol DetailProvider {
    var isEditing: Bool { get }
    var titleProperty: String? { get }
    var subtitleProperty: String? { get }
    var sectionCount: Int { get }
    func sectionTitle(for section: Int) -> String
    func itemCount(for section: Int) -> Int
    func info(section: Int, row: Int) -> DetailItem // TODO: just take IndexPath?
    func filter(for selection: [ModelObject], editing: Bool, context: DetailContext)
}

public class BasicDetailProvider {
    public internal(set) var isEditing: Bool = false
    
    public init() {
    }
}
