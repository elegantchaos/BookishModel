// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol PersonViewer {
    func reveal(person: Person)
}

/**
 Objects that want to observe changes to people
 should implement this protocol.
 */

public protocol PersonChangeObserver: ActionObserver {
    func added(role: Relationship)
    func removed(role: Relationship)
}

/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol PersonConstructionObserver: ActionObserver {
    func created(person: Person)
    func deleted(person: Person)
}

/**
 Common functionality for all person-related actions.
 */

open class PersonAction: ModelAction {
    public static let newPersonKey = "newPerson"
    public static let personKey = "person"
    public static let relationshipKey = "relationship"
    public static let roleKey = "role"
    
    open override func validate(context: ActionContext) -> Bool {
        guard super.validate(context: context) else {
            return false
        }
        
        guard let selection = context[ActionContext.selectionKey] as? [Book] else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewPersonAction(identifier: "NewPerson"),
            AddRelationshipAction(identifier: "AddRelationship"),
            RemoveRelationshipAction(identifier: "RemoveRelationship"),
            DeletePeopleAction(identifier: "DeletePeople"),
            RevealPersonAction(identifier: "RevealPerson"),
            ChangeRelationshipAction(identifier: "ChangeRelationship")
        ]
    }
}

/**
 Action that adds a relationship between a book and a newly created person.
 */

class AddRelationshipAction: PersonAction {
    public override func validate(context: ActionContext) -> Bool {
        guard let _ = context[PersonAction.roleKey] as? String else {
            return false
        }
        
        return super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let role = context[PersonAction.roleKey] as? String,
            let selection = context[ActionContext.selectionKey] as? [Book] {
            let person = Person(context: model)
            let relationship = person.relationship(as: role)
            for book in selection {
                book.addToRelationships(relationship)
            }
            
            context.info.forObservers { (observer: PersonChangeObserver) in
                observer.added(role: relationship)
            }
        }
    }
}

/**
 Action that removes a relationship from a book.
 */

class RemoveRelationshipAction: PersonAction {
    public override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let relationship = context[PersonAction.relationshipKey] as? Relationship {
            for book in selection {
                book.removeFromRelationships(relationship)
            }
            
            context.info.forObservers { (observer: PersonChangeObserver) in
                observer.removed(role: relationship)
            }
            
            if (relationship.books?.count ?? 0) == 0 {
                relationship.managedObjectContext?.delete(relationship)
            }
        }
        
    }
}

/**
 Action that creates a new person.
 */

class NewPersonAction: ModelAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let person = Person(context: model)
        context.info.forObservers { (observer: PersonConstructionObserver) in
            observer.created(person: person)
        }
    }
}

/**
 Action that deletes a person.
 */

class DeletePeopleAction: ModelAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Person] {
            for person in selection {
                context.info.forObservers { (observer: PersonConstructionObserver) in
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
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
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
 Action that updates an existing role by changing the person that
 it applies to.
 */

class ChangeRelationshipAction: PersonAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let relationship = context[PersonAction.relationshipKey] as? Relationship,
            let roleName = relationship.role?.name {
            var newPerson = context[PersonAction.personKey] as? Person
            if newPerson == nil, let newPersonName = context[PersonAction.newPersonKey] as? String {
                print("Made new person \(newPersonName)")
                newPerson = Person(context: model)
                newPerson?.name = newPersonName
            }
            
            if let newPerson = newPerson {
                let newRelationship = newPerson.relationship(as: roleName)
                for book in selection {
                    book.removeFromRelationships(relationship)
                    book.addToRelationships(newRelationship)
                }
                
                print("\(roleName) changed from \(relationship.person!.name!) to \(newPerson.name!)")
            }
        }
    }
}


