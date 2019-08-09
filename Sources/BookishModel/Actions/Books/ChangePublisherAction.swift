// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that updates an existing role by changing the Publisher that
 it applies to.
 */

class ChangePublisherAction: BookAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[PublisherAction.newPublisherKey] as? Publisher != nil) || (context[PublisherAction.newPublisherKey] as? String != nil)
        return info
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            var newPublisher = context[PublisherAction.newPublisherKey] as? Publisher
            if newPublisher == nil, let newPublisherName = context[PublisherAction.newPublisherKey] as? String, !newPublisherName.isEmpty {
                bookActionChannel.log("using publisher name \(newPublisherName)")
                newPublisher = Publisher.named(newPublisherName, in: model, createIfMissing: true)
            }
            
            if let newPublisher = newPublisher {
                for book in selection {
                    if let existingPublisher = book.publisher {
                        if existingPublisher != newPublisher {
                            newPublisher.addToBooks(book)
                            bookActionChannel.log("changed publisher from \(existingPublisher.name!) to \(newPublisher.name!)")
                            context.info.forObservers { (observer: BookChangeObserver) in
                                observer.changed(publisher: existingPublisher, to: newPublisher)
                            }
                    } else {
                            bookActionChannel.log("publisher unchanged \(existingPublisher.name!)")
                        }
                    } else {
                            newPublisher.addToBooks(book)
                            bookActionChannel.log("set publisher to \(newPublisher.name!)")
                            context.info.forObservers { (observer: BookChangeObserver) in
                                observer.added(publisher: newPublisher)
                            }
                    }
                }
            } else if let existingPublisher = context[PublisherAction.publisherKey] as? Publisher {
                bookActionChannel.log("cleared publisher \(existingPublisher.name!)")
                for book in selection {
                    existingPublisher.removeFromBooks(book)
                }
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.removed(publisher: existingPublisher)
                }
            }
        }
    }
}
