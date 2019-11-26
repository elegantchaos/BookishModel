// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Foundation
import Datastore

/**
 Action that splits each of the selected people into two.
 This is useful when a person object actually represents two people
 (this can happen as a result of a Delicious Library import, for example)
 
 The relationships for each of the existing people are duplicated onto the new person.
 */

class SplitPersonAction: PersonAction {
//    func copyRelationships(from: Person, to: Person, context: NSManagedObjectContext) {
//        for fromRelationship in from.relationships {
//            if let role = fromRelationship.role {
//                let toRelationship = to.relationship(as: role)
//                toRelationship.add(fromRelationship.books)
//            }
//        }
//    }
    
    override func validate(context: ActionContext) -> Action.Validation {
        return validateSelection(type: Person.self, context: context, usingPluralTitle: true)
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let selection = context[ActionContext.selectionKey] as? [Person] {

//            let names = selection.compactMap({$0.name}).joined(separator: ", ")
//            let uuids = selection.compactMap({$0.uuid}).map({ "\"\($0)\"" }).joined(separator: ", ")
//            bktChannel.log("""
//                {
//                "name": "split \(names)",
//                "action": "SplitPerson",
//                "people": [ \(uuids) ]
//                },
//                """)
//            
//            for person in selection {
//                let oldName = person.name ?? ""
//                let newPerson = Person(context: model)
//                
//                let trimCharacters = CharacterSet.whitespaces
//                if let explicitName = context[PersonAction.splitNameKey] as? String {
//                    newPerson.name = explicitName
//                    person.name = oldName.replacingOccurrences(of: explicitName, with: "").trimmingCharacters(in: trimCharacters)
//                } else {
//                    let split = oldName.split(separator: ",")
//                    if split.count == 2 {
//                        person.name = String(split[0]).trimmingCharacters(in: trimCharacters)
//                        newPerson.name = String(split[1]).trimmingCharacters(in: trimCharacters)
//                    } else {
//                        let split = oldName.split(separator: " ")
//                        if split.count == 4 {
//                            person.name = split[0...1].joined(separator: " ").trimmingCharacters(in: trimCharacters)
//                            newPerson.name = split[2...3].joined(separator: " ").trimmingCharacters(in: trimCharacters)
//                        } else {
//                            newPerson.name = oldName
//                        }
//                    }
//                }
//                
//                if let uuid = person.uuid, let suffix = context[PersonAction.splitUUIDKey] as? String {
//                    newPerson.uuid = "\(uuid)-\(suffix)"
//                }
//                
//                var log = person.log ?? ""
//                log += "\nSplit from \(person)."
//                newPerson.log = log
//
//                copyRelationships(from: person, to: newPerson, context: model)
//                personActionChannel.log("Split \(oldName) as \(person) and \(newPerson)")
//            }
        }
    }
}
