// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Logger

let entityActionChannel = Logger("EntityActions")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol EntityViewer: ActionObserver {
    func reveal(entity: EntityReference, dismissPopovers: Bool)
}

/**
 Common functionality for all book-related actions.
 */

open class EntityAction: ModelAction {
    
    open class override func standardActions() -> [Action] {
        return [
            NewEntityAction(),
            DeleteEntityAction(),
            RevealEntityAction(),
            AddPublisherAction(),
            RemovePublisherAction(),
            ChangePublisherAction(),
            AddRelationshipAction(),
            RemoveRelationshipAction(),
            ChangeRelationshipAction(),
            AddSeriesAction(),
            RemoveSeriesAction(),
            MergeBookAction()
        ]
    }

    class Arguments {
        let selection: [EntityReference]
        
        init?(from context: ActionContext) {
            guard let selection = context[.selection] as? [EntityReference], selection.count > 0 else {
                return nil
            }
            
            self.selection = selection
        }
    }
}



