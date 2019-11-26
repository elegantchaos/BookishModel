// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action the book's relationships.
 If given an existing relationship, we change either the person it applies to, or the
 role that it represents.
 If no existing relationship is given, we make a new one if we have both a person and
 
 */

class ChangeRelationshipAction: BookAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        let gotRelationship = context[PersonAction.relationshipKey] as? Relationship != nil
        let gotPerson = (context[PersonAction.personKey] as? String) != nil || (context[PersonAction.personKey] as? Person) != nil
        let gotRole = (context[PersonAction.roleKey] as? Role) != nil
        info.enabled = info.enabled &&
            ((gotRelationship && gotPerson) ||
                (gotRelationship && gotRole) ||
                (!gotRelationship && gotPerson && gotRole))
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        let existingRelationship = context[PersonAction.relationshipKey] as? Relationship
        var role = context[PersonAction.roleKey] as? Role
        if role == nil {
            role = existingRelationship?.role
        }
        
//        if let selection = context[ActionContext.selectionKey] as? [Book], let role = role {
//            var updatedPerson = context[PersonAction.personKey] as? Person
//            if updatedPerson == nil, let name = context[PersonAction.personKey] as? String, !name.isEmpty {
//                bookActionChannel.debug("using person name \(name)")
//                updatedPerson = Person.named(name, in: model, createIfMissing: true)
//                updatedPerson?.name = name
//            }
//            
//            if let existingRelationship = existingRelationship, let existingPerson = existingRelationship.person, let updatedPerson = updatedPerson, existingPerson != updatedPerson {
//                // we're switching people
//                let newRelationship = updatedPerson.relationship(as: role)
//                for book in selection {
//                    book.removeRelationship(existingRelationship)
//                    book.addToRelationships(newRelationship)
//                    bookActionChannel.log("changed \(role.name!) from \(existingPerson.name!) to \(updatedPerson.name!)")
//                }
//                context.info.forObservers { (observer: BookChangeObserver) in
//                    observer.replaced(relationship: existingRelationship, with: newRelationship)
//                }
//                
//            } else if let existingRelationship = existingRelationship, let existingPerson = existingRelationship.person, let existingRole = existingRelationship.role, existingRole != role {
//                // we're switching roles
//                let newRelationship = existingPerson.relationship(as: role)
//                for book in selection {
//                    book.removeRelationship(existingRelationship)
//                    book.addToRelationships(newRelationship)
//                    bookActionChannel.log("changed \(existingPerson.name!) from \(existingRole.name!) to \(role.name!)")
//                }
//                context.info.forObservers { (observer: BookChangeObserver) in
//                    observer.replaced(relationship: existingRelationship, with: newRelationship)
//                }
//            } else if existingRelationship == nil, let newPerson = updatedPerson {
//                // we're adding a new relationship
//                let newRelationship = newPerson.relationship(as: role)
//                for book in selection {
//                    bookActionChannel.log("added \(newPerson.name!) as \(role.name!)")
//                    book.addToRelationships(newRelationship)
//                }
//                context.info.forObservers { (observer: BookChangeObserver) in
//                    observer.added(relationship: newRelationship)
//                }
//            } else {
//                // we've been invoked but nothing has changed; just do nothing
//                // (this can happen in certain situations where a UI item loses focus)
//                bookActionChannel.log("skipped - no changes")
//            }
//        }
    }
}
