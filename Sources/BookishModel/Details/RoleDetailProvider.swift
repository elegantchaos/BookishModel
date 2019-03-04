// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RoleDetailProvider: DetailProvider {
    var sortedRelationships = [Relationship]()
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes"),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind),
                ])
        }
        
        return details
    }
    
    override func buildItems() {
        super.buildItems()
        
        var row = items.count
        for index in 0 ..< sortedRelationships.count {
            let relationship = sortedRelationships[index]
            let info = PersonDetailItem(relationship: relationship, absolute: index, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: [ModelObject], editing: Bool, combining: Bool, context: DetailContext) {
        if let role = selection.first as? Role, let sort = context.entitySorting["Relationship"], let relationships = role.relationships?.sortedArray(using: sort) as? [Relationship] {
            sortedRelationships.removeAll()
            sortedRelationships.append(contentsOf: relationships)
        }
        
        let template = SeriesDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

