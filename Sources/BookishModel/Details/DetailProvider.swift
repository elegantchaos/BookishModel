// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public protocol DetailContext {
    var entitySorting: [String:[NSSortDescriptor]] { get }
//    var relationshipSorting: [NSSortDescriptor] { get }
//    var bookSorting: [NSSortDescriptor] { get }
//    var entrySorting: [NSSortDescriptor] { get }
    var showDebug: Bool { get }
}

public protocol DetailOwner {
    static func getProvider() -> DetailProvider
    func getProvider() -> DetailProvider
}

extension DetailOwner {
    public func getProvider() -> DetailProvider {
        return type(of: self).getProvider()
    }
}

public class DetailProvider {
    static let SimpleColumns = [DetailItem.detailColumnID]
    static let LabelledColumns = [DetailItem.headingColumnID, DetailItem.detailColumnID]
    static let EditingColumns = [DetailItem.controlColumnID, DetailItem.headingColumnID, DetailItem.detailColumnID]
    
    public internal(set) var isEditing: Bool = false
    
    internal var details: [DetailSpec] = []
    internal var items = [DetailItem]()
    internal var combinedItems = [DetailItem]()
    internal var shouldCombine = false
    internal var tags: Set<Tag>? = nil

    public init() {
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
    
    public var combinedCount: Int {
        return combinedItems.count
    }
    
    public func combinedInfo(row: Int) -> DetailItem {
        return combinedItems[row]
    }
    
    public var visibleColumns: [String] {
        return isEditing ? DetailProvider.EditingColumns : DetailProvider.LabelledColumns
    }

    public func filter(for selection: ModelSelection, editing: Bool, combining: Bool, context: DetailContext) {
        self.filter(for: selection, template: [], editing: editing, combining: combining, context: context)
    }
    
    internal func filter(for selection: ModelSelection, template: [DetailSpec], editing: Bool, combining: Bool = false, context: DetailContext) {
        shouldCombine = combining
        var filteredDetails = [DetailSpec]()
        for detail in template {
            var includeDetail = false
            let kind = editing ? detail.editableKind : detail.kind
            if kind != DetailSpec.hiddenKind {
                if editing {
                    includeDetail = true
                } else {
                    for item in selection.objects {
                        let value = item.value(forKey: detail.binding)
                        if let string = value as? String {
                            includeDetail = !string.isEmpty
                        } else {
                            includeDetail = value != nil
                        }
                        
                        if includeDetail {
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
        
        rebuildItems()
    }

    func rebuildItems() {
        items.removeAll()
        combinedItems.removeAll()
        buildItems()
        if shouldCombine {
            combineItems()
        }
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

        if let tags = tags, (tags.count > 0) || isEditing {
            let info = TagsDetailItem(tags: tags, absolute: row, index: 0, source: self)
            items.append(info)
        }
    }
    
    public func combineItems() {
        combinedItems.removeAll()
        for section in 0 ..< sectionCount {
            let title = sectionTitle(for: section)
            if !title.isEmpty {
                let item = SectionDetailItem(kind: title, absolute: combinedItems.count, index: 0, placeholder: false, source: self)
                combinedItems.append(item)
            }
            for row in 0 ..< itemCount(for: section) {
                combinedItems.append(info(section: section, row: row))
            }
        }
    }
    
    /**
     Notify the detail provider that some details have been inserted to the object.
    
     Calling this method should cause the provider to update its items (it may just
     call buildItems() again, or may manually insert some new items).
     
     Returns a set of the indexes for the items that the new details will create.
     This information can be used to animate the change in the UI.
    */
    
    public func inserted(details: [ModelObject]) -> IndexSet {
        return IndexSet()
    }

    /**
     Notify the detail provider that some details have been removed from the object.
     
     Calling this method should cause the provider to update its items (it may just
     call buildItems() again, or may manually remove some existing items).
     
     Returns a set of the indexes for the items that will be removed.
     This information can be used to animate the change in the UI.
     */

    public func removed(details: [ModelObject]) -> IndexSet {
        return IndexSet()
    }
    
    /**
     Notify the detail provider that some details have been updated in the object.
     
     Calling this method should cause the provider to update its items (it may just
     call buildItems() again, or may manually alter or re-create some existing items).
     
     Returns a set of the indexes for the items that have updated.
     This information can be used to animate/refresh the UI to reflect the changes.
     */

    public func updated(details: [ModelObject], with: [ModelObject]) -> IndexSet {
        return IndexSet()
    }
    
 }

extension DetailProvider: CustomStringConvertible {
    public var description: String {
        var text = ""
        for i in items {
            text += "\(i)\n"
        }
        return text
    }
}
