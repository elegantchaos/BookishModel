// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Logger

let bookActionChannel = Logger("BookActions")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol BookViewer: ActionObserver {
    func reveal(book: Book, dismissPopovers: Bool)
}

/**
 Objects that want to observe changes to the
 book should implement this protocol.
 */

public protocol BookChangeObserver: ActionObserver {
    func added(relationship: Relationship)
    func removed(relationship: Relationship)
    func replaced(relationship: Relationship, with: Relationship)
    func added(series: Series, position: Int)
    func removed(series: Series)
    func changed(series: Series, to: Series, position: Int)
    func added(publisher: Publisher)
    func changed(publisher: Publisher, to: Publisher)
    func removed(publisher: Publisher)
}

public extension BookChangeObserver {
    func added(relationship: Relationship) {
    }
    
    func removed(relationship: Relationship) {
    }
    
    func replaced(relationship: Relationship, with: Relationship) {
    }
    
    func added(series: Series, position: Int) {
    }
    
    func removed(series: Series) {
    }
    
    func changed(series: Series, to: Series, position: Int) {
    }
    
    func added(publisher: Publisher) {
    }
    
    func changed(publisher: Publisher, to: Publisher) {
    }

    func removed(publisher: Publisher) {
    }
}

/**
 Objects that want to observe changes to books should
 implement this protocol.
 */

public protocol EntityLifecycleObserver: ActionObserver {
    func created(entities: [Book])
    func deleted(entities: [Book])
}

extension ActionKey {
    public static let entity: ActionKey = "entity"
}

/**
 Common functionality for all book-related actions.
 */

open class EntityAction: ModelAction {
    
    open class override func standardActions() -> [Action] {
        return [
            NewEntityAction(),
            DeleteEntityAction(),
            AddPublisherAction(),
            RemovePublisherAction(),
            ChangePublisherAction(),
            AddRelationshipAction(),
            RemoveRelationshipAction(),
            ChangeRelationshipAction(),
            AddSeriesAction(),
            RemoveSeriesAction(),
            RevealBookAction(),
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



