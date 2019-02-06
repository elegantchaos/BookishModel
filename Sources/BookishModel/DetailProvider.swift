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

public class DetailProvider {
    public internal(set) var isEditing: Bool = false
    internal var details: [DetailSpec] = []
    internal let template: [DetailSpec]
    internal var items = [DetailItem]()

    public init(template: [DetailSpec] = []) {
        self.template = template
    }
    

    public var titleProperty: String? {
        return "name"
    }
    
    public var subtitleProperty: String? {
        return nil
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
    
    public func info(section: Int, row: Int) -> DetailItem {
        return items[row]
    }
    
    public func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        
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
        
        details = filteredDetails
        isEditing = editing

        items.removeAll()
        buildItems()
    }

    func buildItems() {
        var row = items.count
        let detailCount = details.count
        for index in 0 ..< detailCount {
            let spec = details[index]
            let info = SimpleDetailItem(spec: spec, absolute: row, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
}
