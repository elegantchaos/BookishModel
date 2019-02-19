// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData
import Logger

let bookActionChannel = Logger("BookActions")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol BookViewer {
    func reveal(book: Book)
}

/**
 Objects that want to observe changes to the
 book should implement this protocol.
 */

public protocol BookChangeObserver: ActionObserver {
    func added(relationship: Relationship)
    func removed(relationship: Relationship)
    func replaced(relationship: Relationship, with: Relationship)
    func added(series: Series)
    func removed(series: Series)
    func added(publisher: Publisher)
    func removed(publisher: Publisher)
}

public extension BookChangeObserver {
    func added(relationship: Relationship) {
    }
    
    func removed(relationship: Relationship) {
    }
    
    func replaced(relationship: Relationship, with: Relationship) {
    }
    
    func added(series: Series) {
    }
    
    func removed(series: Series) {
    }
    
    func added(publisher: Publisher) {
    }
    
    func removed(publisher: Publisher) {
    }
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

open class BookAction: SyncModelAction {
    public static let bookKey = "book"
    
    open class override func standardActions() -> [Action] {
        return [
            NewBookAction(identifier: "NewBook"),
            DeleteBookAction(identifier: "DeleteBook"),
            AddPublisherAction(identifier: "AddPublisher"),
            RemovePublisherAction(identifier: "RemovePublisher"),
            ChangePublisherAction(identifier: "ChangePublisher"),
            AddRelationshipAction(identifier: "AddRelationship"),
            RemoveRelationshipAction(identifier: "RemoveRelationship"),
            ChangeRelationshipAction(identifier: "ChangeRelationship"),
            AddSeriesAction(identifier: "AddSeries"),
            RemoveSeriesAction(identifier: "RemoveSeries"),
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

public class DeleteBookAction: BookAction {
    
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
        if let role = context[PersonAction.roleKey] as? String, let selection = context[ActionContext.selectionKey] as? [Book], selection.count > 0 {
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
            
            context.info.forObservers { (observer: BookChangeObserver) in
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
        return (context[PublisherAction.newPublisherKey] as? Publisher != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let publisher = context[PublisherAction.newPublisherKey] as? Publisher {
            for book in selection {
                publisher.removeFromBooks(book)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(publisher: publisher)
            }
        }
        
    }
}
/**
 Action the book's relationships.
 If given an existing relationship, we change either the person it applies to, or the
 role that it represents.
 If no existing relationship is given, we make a new one if we have both a person and
 
 */

class ChangeRelationshipAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        let gotRelationship = context[PersonAction.relationshipKey] as? Relationship != nil
        let gotPerson = (context[PersonAction.personKey] as? String) != nil || (context[PersonAction.personKey] as? Person) != nil
        let gotRole = (context[PersonAction.roleKey] as? Role) != nil
        return super.validate(context: context) &&
            ((gotRelationship && gotPerson) ||
                (gotRelationship && gotRole) ||
                (!gotRelationship && gotPerson && gotRole))
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let existingRelationship = context[PersonAction.relationshipKey] as? Relationship
        var role = context[PersonAction.roleKey] as? Role
        if role == nil {
            role = existingRelationship?.role
        }
        
        if let selection = context[ActionContext.selectionKey] as? [Book], let role = role {
            var updatedPerson = context[PersonAction.personKey] as? Person
            if updatedPerson == nil, let name = context[PersonAction.personKey] as? String, !name.isEmpty {
                bookActionChannel.debug("using person name \(name)")
                updatedPerson = Person.named(name, in: model, createIfMissing: true)
                updatedPerson?.name = name
            }
            
            if let existingRelationship = existingRelationship, let existingPerson = existingRelationship.person, let updatedPerson = updatedPerson, existingPerson != updatedPerson {
                // we're switching people
                let newRelationship = updatedPerson.relationship(as: role)
                for book in selection {
                    book.removeRelationship(existingRelationship)
                    book.addToRelationships(newRelationship)
                    bookActionChannel.log("changed \(role.name!) from \(existingPerson.name!) to \(updatedPerson.name!)")
                }
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.replaced(relationship: existingRelationship, with: newRelationship)
                }
                
            } else if let existingRelationship = existingRelationship, let existingPerson = existingRelationship.person, let existingRole = existingRelationship.role, existingRole != role {
                // we're switching roles
                let newRelationship = existingPerson.relationship(as: role)
                for book in selection {
                    book.removeRelationship(existingRelationship)
                    book.addToRelationships(newRelationship)
                    bookActionChannel.log("changed \(existingPerson.name!) from \(existingRole.name!) to \(role.name!)")
                }
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.replaced(relationship: existingRelationship, with: newRelationship)
                }
            } else if existingRelationship == nil, let newPerson = updatedPerson {
                // we're adding a new relationship
                let newRelationship = newPerson.relationship(as: role)
                for book in selection {
                    bookActionChannel.log("added \(newPerson.name!) as \(role.name!)")
                    book.addToRelationships(newRelationship)
                }
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.added(relationship: newRelationship)
                }
            } else {
                // we've been invoked but nothing has changed; just do nothing
                // (this can happen in certain situations where a UI item loses focus)
                bookActionChannel.log("skipped - no changes")
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
        let gotPublisher = (context[PublisherAction.newPublisherKey] as? Publisher != nil) || (context[PublisherAction.newPublisherKey] as? String != nil)
        return gotPublisher && super.validate(context: context)
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
                        }
                    } else {
                            newPublisher.addToBooks(book)
                            bookActionChannel.log("set publisher to \(newPublisher.name!)")
                    }
                }
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.added(publisher: newPublisher)
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

/**
 Action that adds a relationship between a book and a newly created Series.
 */

class AddSeriesAction: BookAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            let series = Series(context: model)
            series.name = "New Series"
            for book in selection {
                let entry = SeriesEntry(context: model)
                entry.book = book
                entry.series = series
                entry.position = 1
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.added(series: series)
            }
        }
    }
}

/**
 Action that removes a relationship from a book.
 */

class RemoveSeriesAction: BookAction {
    public override func validate(context: ActionContext) -> Bool {
        return (context[SeriesAction.seriesKey] as? Series != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let series = context[SeriesAction.seriesKey] as? Series {
            for book in selection {
                book.removeFromSeries(series)
            }
            
            context.info.forObservers { (observer: BookChangeObserver) in
                observer.removed(series: series)
            }
        }
        
    }
}

/**
 Action that updates an existing role by changing the Series that
 it applies to.
 */

class ChangeSeriesAction: BookAction {
    override func validate(context: ActionContext) -> Bool {
        let gotSeries =
            (context[SeriesAction.seriesKey] as? Series != nil) ||
                (context[SeriesAction.newSeriesKey] as? Series != nil) ||
                (context[SeriesAction.newSeriesKey] as? String != nil)
        return gotSeries && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            let existingSeries = context[SeriesAction.seriesKey] as? Series
            let position = context[SeriesAction.positionKey] as? Int
            var updatedSeries = context[SeriesAction.newSeriesKey] as? Series
            
            // if we weren't given a series, but were given a name, make a new series with that name
            if updatedSeries == nil, let newSeriesName = context[SeriesAction.newSeriesKey] as? String {
                updatedSeries = Series(context: model)
                updatedSeries?.name = newSeriesName
                bookActionChannel.log("Made new Series \(newSeriesName)")
            }
            
            if let series = updatedSeries {
                // we've got a series to change to, so do it
                for book in selection {
                    var bookPosition = position
                    if let existingSeries = existingSeries {
                        if bookPosition == nil {
                            bookPosition = book.position(in: existingSeries)
                        }
                        book.removeFromSeries(existingSeries)
                        bookActionChannel.debug("removed from \(existingSeries.name!)")
                    }
                    
                    book.addToSeries(series, position: bookPosition ?? 0)
                    bookActionChannel.debug("added to \(series.name!)")
                }
            } else if let existingSeries = existingSeries, let updatedPosition = position {
                // we've not got a series to change to, but we might be updating our position
                // in an existing series
                for book in selection {
                    book.setPosition(in: existingSeries, to: updatedPosition)
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
