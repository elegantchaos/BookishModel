// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that merges together a number of people.
 The first person in the selection is treated as the primary, and is retained.
 All the other people are removed, after transferring any relationships to the first person.
 */

class MergePersonAction: PersonAction {
//    func moveRelationships(from: Person, to: Person, context: NSManagedObjectContext) {
//        for fromRelationship in from.relationships {
//            if let role = fromRelationship.role {
//                let books = fromRelationship.books
//                let toRelationship = to.relationship(as: role)
//                toRelationship.add(books)
//                fromRelationship.remove(books)
//                personActionChannel.log("Updated \(toRelationship)")
//            }
//            from.remove(fromRelationship)
//            context.delete(fromRelationship)
//        }
//    }
    
    override func validate(context: ActionContext) -> Action.Validation {
        return validateSelection(type: Person.self, context: context, minimumToEnable: 2, usingPluralTitle: false)
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//        if let selection = context[.selection] as? [Person], let primary = selection.first {
//
//            let uuids = selection.compactMap({$0.uuid}).map({ "\"\($0)\"" }).joined(separator: ", ")
//            bktChannel.log("""
//                {
//                        "name": "merge \(primary.name ?? "")",
//                        "action": "MergePerson",
//                        "people": [ \(uuids) ]
//                },
//            """)
//
//            var log = primary.log ?? ""
//            let others = selection.dropFirst()
//            personActionChannel.log("Merging \(primary) with \(others)")
//            for person in others {
//                moveRelationships(from: person, to: primary, context: model)
//                model.delete(person)
//                log += "\nMerged with \(person).\n"
//            }
//            primary.log = log
//        }
    }
}
