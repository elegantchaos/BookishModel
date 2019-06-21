// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RoleDetailProvider: DetailProvider {
    var sortedPeople = [Person]()
    
    public class func standardDetails(showDebug: Bool) -> [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes", viewAs: DetailSpec.hiddenKind, editAs: DetailSpec.textKind),
            DetailSpec(binding: "modified", viewAs: DetailSpec.timeKind),
        ]
        
        if showDebug {
            details.append(contentsOf: [
                DetailSpec(binding: "uuid", viewAs: DetailSpec.textKind),
                DetailSpec(binding: "log", viewAs: DetailSpec.textKind, isDebug: true),
                DetailSpec(binding: "imageURL", viewAs: DetailSpec.textKind, isDebug: true),
                ])
        }
        
        return details
    }
    
    override public var visibleColumns: [String] {
        return DetailProvider.LabelledColumns
    }

    override func buildItems() {
        super.buildItems()
        
        var row = items.count
        for index in 0 ..< sortedPeople.count {
            let person = sortedPeople[index]
            let info = PersonDetailItem(person: person, absolute: index, index: index, source: self)
            items.append(info)
            row += 1
        }
    }
    
    override func filter(for selection: Selection<ModelObject>, editing: Bool, combining: Bool, context: DetailContext) {
        // TODO: handle multiple selection properly
        if let role = selection.objects.first as? Role, let sort = context.entitySorting["Relationship"], let relationships = role.relationships?.sortedArray(using: sort) as? [Relationship] {
            let people = relationships.compactMap { $0.person }
            sortedPeople.removeAll()
            sortedPeople.append(contentsOf: people)
        }
        
        let template = RoleDetailProvider.standardDetails(showDebug: context.showDebug)
        super.filter(for: selection, template: template, editing: editing, combining: combining, context: context)
    }
}

