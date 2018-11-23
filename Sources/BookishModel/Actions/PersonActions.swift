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

open class PersonAction: Action {
    public static let newPersonKey = "newPerson"
    public static let personKey = "person"
    public static let relationshipKey = "relationship"
    public static let roleKey = "role"

    open override func validate(context: ActionContext) -> Bool {
        guard let selection = context[ActionContext.selectionKey] as? [Book] else {
            return false
        }
        
        guard let _ = context[ActionContext.modelKey] as? NSManagedObjectContext else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class func standardActions() -> [Action] {
        return [
            NewPersonAction(identifier: "NewPerson"),
            AddRelationshipAction(identifier: "AddRelationship"),
            RemoveRelationshipAction(identifier: "RemoveRelationship"),
            DeletePersonAction(identifier: "DeletePerson"),
            RevealPersonAction(identifier: "RevealPerson"),
            ChangeRolePersonAction(identifier: "ChangeRolePerson")
        ]
    }
}

/**
 Action that adds a relationship between a book and a newly created person.
 */

class AddRelationshipAction: PersonAction {
    public override func validate(context: ActionContext) -> Bool {
        guard let _ = context[PersonAction.relationshipKey] as? String else {
            return false
        }
        
        return super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, completed: @escaping Completion) {
        if
            let role = context[PersonAction.roleKey] as? String,
            let selection = context[ActionContext.selectionKey] as? [Book],
            let moc = context[ActionContext.modelKey] as? NSManagedObjectContext {
            moc.perform {
                let person = Person(context: moc)
                let relationship = person.relationship(as: role)
                for book in selection {
                    book.addToRelationships(relationship)
                }
                
                context.info.forObservers { (observer: PersonChangeObserver) in
                    observer.added(role: relationship)
                }
                completed()
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
    
    public override func perform(context: ActionContext) {
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

class NewPersonAction: Action {
    public override func perform(context: ActionContext, completed: @escaping Completion) {
        if let moc = context[ActionContext.modelKey] as? NSManagedObjectContext {
            
            moc.perform {
                let person = Person(context: moc)
                context.info.forObservers { (observer: PersonConstructionObserver) in
                    observer.created(person: person)
                }
                completed()
            }

        }
    }
}

/**
 Action that deletes a person.
 */

class DeletePersonAction: Action {
    public override func perform(context: ActionContext, completed: @escaping Completion) {
        if let selection = context[ActionContext.selectionKey] as? [Person],
            let moc = context[ActionContext.modelKey] as? NSManagedObjectContext {
            moc.perform {
                for person in selection {
                    context.info.forObservers { (observer: PersonConstructionObserver) in
                        observer.deleted(person: person)
                    }
                    
                    moc.delete(person)
                    completed()
                }
            }
            
        }
    }
}

/**
 Action that reveals a person in the UI.
 */

class RevealPersonAction: PersonAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext) {
        if let role = context[PersonAction.relationshipKey] as? Relationship, let person = role.person,
            let viewer = context[ActionContext.rootKey] as? PersonViewer {
            viewer.reveal(person: person)
        }
    }
}

/**
 Action that updates an existing role by changing the person that
 it applies to.
 */

class ChangeRolePersonAction: PersonAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext) {
        
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let role = context[PersonAction.relationshipKey] as? Relationship,
            let managedObjectContext = role.managedObjectContext,
            let roleName = role.role?.name {
            
            var newPerson = context[PersonAction.personKey] as? Person
            if newPerson == nil, let newPersonName = context[PersonAction.newPersonKey] as? String {
                print("Made new person \(newPersonName)")
                newPerson = Person(context: managedObjectContext)
                newPerson?.name = newPersonName
            }
            
            if let newPerson = newPerson {
                let newRole = newPerson.relationship(as: roleName)
                for book in selection {
                    book.removeFromRelationships(role)
                    book.addToRelationships(newRole)
                }
                
                print("\(roleName) changed from \(role.person!.name!) to \(newPerson.name!)")
            }
        }
    }
}


