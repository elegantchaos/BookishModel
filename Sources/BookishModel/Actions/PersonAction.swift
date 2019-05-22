// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions
import Logger

let personActionChannel = Channel("com.elegantchaos.bookish.model.PersonAction")
let bktChannel = Channel("com.elegantchaos.bookish.model.BktOutput")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol PersonViewer {
    func reveal(person: Person)
}


/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol PersonLifecycleObserver: ActionObserver {
    func created(person: Person)
    func deleted(person: Person)
}

/**
 Common functionality for all person-related actions.
 */

open class PersonAction: SyncModelAction {
    public static let personKey = "person"
    public static let relationshipKey = "relationship"
    public static let roleKey = "role"
    public static let splitNameKey = "splitName"
    public static let splitUUIDKey = "splitUUID"
    
    open override func validate(context: ActionContext) -> Bool {
        guard super.validate(context: context) else {
            return false
        }
        
        guard let selection = context[ActionContext.selectionKey] as? [Person] else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewPersonAction(),
            DeletePersonAction(),
            RevealPersonAction(),
            MergePersonAction(),
            SplitPersonAction()
        ]
    }
}

/**
 Action that creates a new person.
 */

class NewPersonAction: PersonAction {
    public override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context) // we don't need a selection, so we skip to ModelAction's validation
    }

    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let person = Person(context: model)
        context.info.forObservers { (observer: PersonLifecycleObserver) in
            observer.created(person: person)
        }
    }
}

/**
 Action that deletes a person.
 */

class DeletePersonAction: PersonAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Person] {
            for person in selection {
                context.info.forObservers { (observer: PersonLifecycleObserver) in
                    observer.deleted(person: person)
                }
                
                model.delete(person)
            }
        }
    }
}

/**
 Action that reveals a person in the UI.
 The person to reveal can either be set as the personKey, or extracted from a relationship set as the relationshipKey
 */

class RevealPersonAction: PersonAction {
    override func validate(context: ActionContext) -> Bool {
        var ok = (context[PersonAction.relationshipKey] as? Relationship != nil)
        ok = ok || (context[PersonAction.personKey] as? Person != nil)
        ok = ok && (context[ActionContext.rootKey] as? PersonViewer != nil) && super.modelValidate(context: context)
        return ok
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let viewer = context[ActionContext.rootKey] as? PersonViewer {
            if let person = context[PersonAction.personKey] as? Person {
                viewer.reveal(person: person)
            } else if let role = context[PersonAction.relationshipKey] as? Relationship, let person = role.person {
                viewer.reveal(person: person)
            }
        }
    }
}

/**
 Action that merges together a number of people.
 The first person in the selection is treated as the primary, and is retained.
 All the other people are removed, after transferring any relationships to the first person.
 */

class MergePersonAction: PersonAction {
    func moveRelationships(from: Person, to: Person, context: NSManagedObjectContext) {
        if let relationships = from.relationships as? Set<Relationship> {
            for fromRelationship in relationships {
                if let role = fromRelationship.role, let books = fromRelationship.books {
                    let toRelationship = to.relationship(as: role)
                    toRelationship.addToBooks(books)
                    fromRelationship.removeFromBooks(books)
                    personActionChannel.log("Updated \(toRelationship)")
                }
                from.removeFromRelationships(fromRelationship)
                context.delete(fromRelationship)
            }
        }
    }
    
    override func validate(context: ActionContext) -> Bool {
        guard let selection = context[ActionContext.selectionKey] as? [Person], super.validate(context: context) else {
            return false
        }

        return selection.count > 1
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Person], let primary = selection.first {
            
            let uuids = selection.compactMap({$0.uuid}).map({ "\"\($0)\"" }).joined(separator: ", ")
            bktChannel.log("""
                {
                        "name": "merge \(primary.name ?? "")",
                        "action": "MergePerson",
                        "people": [ \(uuids) ]
                },
            """)
            
            var log = primary.log ?? ""
            let others = selection.dropFirst()
            personActionChannel.log("Merging \(primary) with \(others)")
            for person in others {
                moveRelationships(from: person, to: primary, context: model)
                model.delete(person)
                log += "\nMerged with \(person).\n"
            }
            primary.log = log
        }
    }
}


/**
 Action that splits each of the selected people into two.
 This is useful when a person object actually represents two people
 (this can happen as a result of a Delicious Library import, for example)
 
 The relationships for each of the existing people are duplicated onto the new person.
 */

class SplitPersonAction: PersonAction {
    func copyRelationships(from: Person, to: Person, context: NSManagedObjectContext) {
        if let relationships = from.relationships as? Set<Relationship> {
            for fromRelationship in relationships {
                if let role = fromRelationship.role, let books = fromRelationship.books {
                    let toRelationship = to.relationship(as: role)
                    toRelationship.addToBooks(books)
                }
            }
        }
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Person] {

            let names = selection.compactMap({$0.name}).joined(separator: ", ")
            let uuids = selection.compactMap({$0.uuid}).map({ "\"\($0)\"" }).joined(separator: ", ")
            bktChannel.log("""
                {
                "name": "split \(names)",
                "action": "SplitPerson",
                "people": [ \(uuids) ]
                },
                """)
            
            for person in selection {
                let oldName = person.name ?? ""
                let newPerson = Person(context: model)
                
                let trimCharacters = CharacterSet.whitespaces
                if let explicitName = context[PersonAction.splitNameKey] as? String {
                    newPerson.name = explicitName
                    person.name = oldName.replacingOccurrences(of: explicitName, with: "").trimmingCharacters(in: trimCharacters)
                } else {
                    let split = oldName.split(separator: ",")
                    if split.count == 2 {
                        person.name = String(split[0]).trimmingCharacters(in: trimCharacters)
                        newPerson.name = String(split[1]).trimmingCharacters(in: trimCharacters)
                    } else {
                        let split = oldName.split(separator: " ")
                        if split.count == 4 {
                            person.name = split[0...1].joined(separator: " ").trimmingCharacters(in: trimCharacters)
                            newPerson.name = split[2...3].joined(separator: " ").trimmingCharacters(in: trimCharacters)
                        } else {
                            newPerson.name = oldName
                        }
                    }
                }
                
                if let uuid = person.uuid, let suffix = context[PersonAction.splitUUIDKey] as? String {
                    newPerson.uuid = "\(uuid)-\(suffix)"
                }
                
                var log = person.log ?? ""
                log += "\nSplit from \(person)."
                newPerson.log = log

                copyRelationships(from: person, to: newPerson, context: model)
                personActionChannel.log("Split \(oldName) as \(person) and \(newPerson)")
            }
        }
    }
}
