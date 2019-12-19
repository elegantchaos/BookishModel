// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol PublisherViewer {
    func reveal(publisher: Publisher)
}


/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol PublisherLifecycleObserver: ActionObserver {
    func created(publisher: Publisher)
    func deleted(publisher: Publisher)
}

extension ActionKey {
    public static let publisherKey: ActionKey = "publisher"
    public static let newPublisherKey: ActionKey = "newPublisher"
}

/**
 Common functionality for all Publisher-related actions.
 */

open class PublisherAction: ModelAction {
    
    open override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        
        if info.enabled, let selection = context[.selection] as? [Publisher] {
            info.enabled = selection.count > 0
        } else {
            info.enabled = false
        }
        
        return info
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewPublisherAction(),
            DeletePublisherAction(),
            RevealPublisherAction(),
        ]
    }
}



/**
 Action that creates a new Publisher.
 */

class NewPublisherAction: PublisherAction {
    override func validate(context: ActionContext) -> Validation {
        return modelValidate(context: context)
    }
    
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
//        let publisher = Publisher(context: model)
//        context.info.forObservers { (observer: PublisherLifecycleObserver) in
//            observer.created(publisher: publisher)
//        }
    }
}

/**
 Action that deletes a Publisher.
 */

class DeletePublisherAction: PublisherAction {
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
        if let selection = context[.selection] as? [Publisher] {
            for publisher in selection {
                context.info.forObservers { (observer: PublisherLifecycleObserver) in
                    observer.deleted(publisher: publisher)
                }
                
//                model.delete(publisher)
            }
        }
    }
}

/**
 Action that reveals a Publisher in the UI.
 */

class RevealPublisherAction: PublisherAction {
    override func validate(context: ActionContext) -> Validation {
        var info = modelValidate(context: context)
        if info.enabled {
            info.enabled = (context[.publisherKey] as? Publisher != nil)
        }
        return info
    }
    
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
        if let viewer = context[.root] as? PublisherViewer {
            if let publisher = context[.publisherKey] as? Publisher {
                viewer.reveal(publisher: publisher)
            }
        }
    }
}
