// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol PublisherViewer {
    func reveal(publisher: Publisher)
}

/**
 Objects that want to observe changes to publishers
 should implement this protocol.
 */

public protocol PublisherChangeObserver: ActionObserver {
    func added(publisher: Publisher)
    func removed(publisher: Publisher)
}

/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol PublisherLifecycleObserver: ActionObserver {
    func created(publisher: Publisher)
    func deleted(publisher: Publisher)
}

/**
 Common functionality for all Publisher-related actions.
 */

open class PublisherAction: ModelAction {
    public static let newPublisherKey = "newPublisher"
    public static let publisherKey = "publisher"
    
    open override func validate(context: ActionContext) -> Bool {
        guard super.validate(context: context) else {
            return false
        }
        
        guard let selection = context[ActionContext.selectionKey] as? [Publisher] else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewPublisherAction(identifier: "NewPublisher"),
            DeletePublisherAction(identifier: "DeletePublisher"),
            RevealPublisherAction(identifier: "RevealPublisher"),
            ChangePublisherAction(identifier: "ChangePublisher")
        ]
    }
}



/**
 Action that creates a new Publisher.
 */

class NewPublisherAction: PublisherAction {
    override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let publisher = Publisher(context: model)
        context.info.forObservers { (observer: PublisherLifecycleObserver) in
            observer.created(publisher: publisher)
        }
    }
}

/**
 Action that deletes a Publisher.
 */

class DeletePublisherAction: PublisherAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Publisher] {
            for publisher in selection {
                context.info.forObservers { (observer: PublisherLifecycleObserver) in
                    observer.deleted(publisher: publisher)
                }
                
                model.delete(publisher)
            }
        }
    }
}

/**
 Action that reveals a Publisher in the UI.
 */

class RevealPublisherAction: PublisherAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PublisherAction.publisherKey] as? Publisher != nil) && modelValidate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let viewer = context[ActionContext.rootKey] as? PublisherViewer {
            if let publisher = context[PublisherAction.publisherKey] as? Publisher {
                viewer.reveal(publisher: publisher)
            }
        }
    }
}

/**
 Action that updates an existing role by changing the Publisher that
 it applies to.
 */

class ChangePublisherAction: PublisherAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PublisherAction.publisherKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            var newPublisher = context[PublisherAction.publisherKey] as? Publisher
            if newPublisher == nil, let newPublisherName = context[PublisherAction.newPublisherKey] as? String {
                print("Made new Publisher \(newPublisherName)")
                newPublisher = Publisher(context: model)
                newPublisher?.name = newPublisherName
            }
            
            if let newPublisher = newPublisher {
                for book in selection {
                    newPublisher.addToBooks(book)
                    print("publisher changed from \(book.publisher!.name!) to \(newPublisher.name!)")
                }
            }
        }
    }
}
