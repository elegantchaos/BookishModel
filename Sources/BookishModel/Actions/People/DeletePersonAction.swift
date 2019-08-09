// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that deletes a person.
 */

class DeletePersonAction: PersonAction {
    open override func validate(context: ActionContext) -> Action.Validation {
        return validateSelection(type: Person.self, context: context, usingPluralTitle: true)
    }

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

