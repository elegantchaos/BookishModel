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

open class PersonAction: ModelAction {
    public static let newPersonKey = "newPerson"
    public static let personKey = "person"
    public static let relationshipKey = "relationship"
    public static let roleKey = "role"
    
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
            NewPersonAction(identifier: "NewPerson"),
            DeletePersonAction(identifier: "DeletePerson"),
            RevealPersonAction(identifier: "RevealPerson"),
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


