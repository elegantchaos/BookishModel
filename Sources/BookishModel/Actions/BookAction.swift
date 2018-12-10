// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol BookViewer {
    func reveal(book: Book)
}

/**
 Objects that want to observe changes to people
 should implement this protocol.
 */

public protocol BookChangeObserver: ActionObserver {
    func added(relationship: Relationship)
    func removed(relationship: Relationship)
}
/**
 Objects that want to observe changes to books should
 implement this protocol.
 */

public protocol BookLifecycleObserver: ActionObserver {
    func created(books: [Book])
    func deleted(books: [Book])
}

/**
 Common functionality for all book-related actions.
 */

open class BookAction: ModelAction {
    public static let bookKey = "book"

    open class override func standardActions() -> [Action] {
        return [
            NewBookAction(identifier: "NewBook"),
            DeleteBooksAction(identifier: "DeleteBooks"),
            AddPublisherAction(identifier: "AddPublisher"),
            RemovePublisherAction(identifier: "RemovePublisher"),
            AddRelationshipAction(identifier: "AddRelationship"),
            RemoveRelationshipAction(identifier: "RemoveRelationship"),
            ChangeRelationshipAction(identifier: "ChangeRelationship"),
            ChangePublisherAction(identifier: "ChangePublisher"),
            RevealBookAction(identifier: "RevealBook")
        ]
    }

    open override func validate(context: ActionContext) -> Bool {
        guard let selection = context[ActionContext.selectionKey] as? [Book] else {
            return false
        }
        
        return (selection.count > 0) && super.validate(context: context)
    }
}

/**
 Action to inserts a new book.
 */

public class NewBookAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context) // we don't need a selection, so we skip to ModelAction's validation
    }
    
    override public func perform(context: ActionContext, model: NSManagedObjectContext) {
        let book = Book(context: model)
        context.info.forObservers { (observer: BookLifecycleObserver) in
            observer.created(books: [book])
        }
    }
}

/**
 Action that deletes a book.
 */

public class DeleteBooksAction: BookAction {
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            for book in selection {
                model.delete(book)
            }
            context.info.forObservers { (observer: BookLifecycleObserver) in
                observer.deleted(books: selection)
            }
        }
    }
    
}


/**
 Action that adds a relationship between a book and a newly created person.
 */

class AddRelationshipAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        guard let _ = context[PersonAction.roleKey] as? String else {
            return false
        }
        
        return super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let role = context[PersonAction.roleKey] as? String,
            let selection = context[ActionContext.selectionKey] as? [Book] {
            let person = Person(context: model)
            let relationship = person.relationship(as: role)
            for book in selection {
                book.addToRelationships(relationship)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.added(relationship: relationship)
            }
        }
    }
}

/**
 Action that removes a relationship from a book.
 */

class RemoveRelationshipAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let relationship = context[PersonAction.relationshipKey] as? Relationship {
            for book in selection {
                book.removeFromRelationships(relationship)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(relationship: relationship)
            }
            
            if (relationship.books?.count ?? 0) == 0 {
                relationship.managedObjectContext?.delete(relationship)
            }
        }
        
    }
}

/**
 Action that adds a relationship between a book and a newly created Publisher.
 */

class AddPublisherAction: BookAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book] {
            let publisher = Publisher(context: model)
            for book in selection {
                publisher.addToBooks(book)
            }
            
            context.info.forObservers { (observer: PublisherChangeObserver) in
                observer.added(publisher: publisher)
            }
        }
    }
}

/**
 Action that removes a relationship from a book.
 */

class RemovePublisherAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        return (context[PublisherAction.publisherKey] as? Publisher != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let publisher = context[PublisherAction.publisherKey] as? Publisher {
            for book in selection {
                publisher.removeFromBooks(book)
            }
            
            context.info.forObservers { (observer: PublisherChangeObserver) in
                observer.removed(publisher: publisher)
            }
        }
        
    }
}
/**
 Action that updates an existing role by changing the person that
 it applies to.
 */

class ChangeRelationshipAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[PersonAction.relationshipKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let relationship = context[PersonAction.relationshipKey] as? Relationship,
            let roleName = relationship.role?.name {
            var newPerson = context[PersonAction.personKey] as? Person
            if newPerson == nil, let newPersonName = context[PersonAction.newPersonKey] as? String {
                print("Made new person \(newPersonName)")
                newPerson = Person(context: model)
                newPerson?.name = newPersonName
            }
            
            if let newPerson = newPerson {
                let newRelationship = newPerson.relationship(as: roleName)
                for book in selection {
                    book.removeFromRelationships(relationship)
                    book.addToRelationships(newRelationship)
                }
                
                print("\(roleName) changed from \(relationship.person!.name!) to \(newPerson.name!)")
            }
        }
    }
}

/**
 Action that updates an existing role by changing the Publisher that
 it applies to.
 */

class ChangePublisherAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        let gotPublisher = (context[PublisherAction.publisherKey] as? Publisher != nil) || (context[PublisherAction.newPublisherKey] as? String != nil)
        return gotPublisher && super.validate(context: context)
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

/**
 Action that shows a book in the user interface.
 */

class RevealBookAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        let book = context[BookAction.bookKey] as? Book
        return (book != nil) && super.modelValidate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let book = context[BookAction.bookKey] as? Book,
            let viewer = context[ActionContext.rootKey] as? BookViewer {
            viewer.reveal(book: book)
        }
    }
}
