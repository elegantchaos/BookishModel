// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that deletes some model entities.
 */

public class DeleteEntityAction: EntityAction {
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        guard let selection = context[.selection] as? [EntityReference] else {
            completion(.failure(Error.missingSelection))
            return
        }
        
        store.delete(entities: selection) {
            completion(.ok)
        }
    }
}

