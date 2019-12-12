// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that adds a relationship between a book and a newly created person.
 */

class AddRelationshipAction: EntityAction {
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && ((context[.roleKey] as? String) != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//        if let role = context[PersonAction.roleKey] as? String, let selection = context[.selection] as? [Book], selection.count > 0 {
//            let person = Person(context: model)
//            let relationship = person.relationship(as: role)
//            for book in selection {
//                book.addToRelationships(relationship)
//            }
//
//            context.info.forObservers { (observer: BookChangeObserver) in
//                observer.added(relationship: relationship)
//            }
//        }
    }
}
