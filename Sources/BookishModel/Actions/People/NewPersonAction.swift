// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that creates a new person.
 */

class NewPersonAction: PersonAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let person = Person(context: model)
        context.info.forObservers { (observer: PersonLifecycleObserver) in
            observer.created(person: person)
        }
    }
}
