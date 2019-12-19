// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action to inserts a new book.
 */

public class NewEntityAction: EntityAction {
    public override func validate(context: ActionContext) -> Validation {
        // we don't need a selection, so we skip to ModelAction's validation
        return modelValidate(context: context)
    }
    
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
        guard let type = context[.entityType] as? EntityType else {
            completion(.ok)
            return
        }
        
        let book = collection.entity(named: "Untitled", createAs: type)
        collection.store.get(entity: book) { result in
            completion(.ok)
        }
    }
}
