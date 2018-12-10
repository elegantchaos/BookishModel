// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


class BookActionTests: ModelActionTestCase, BookViewer, BookLifecycleObserver, BookChangeObserver, PublisherChangeObserver {
    var bookObserved: Book?
    var relationshipObserved: Relationship?
    var publisherObserved: Publisher?
    
    func added(publisher: Publisher) {
        publisherObserved = publisher
    }
    
    func removed(publisher: Publisher) {
        publisherObserved = publisher
    }
    
    func removed(relationship: Relationship) {
        relationshipObserved = relationship
    }
    
    func added(relationship: Relationship) {
        relationshipObserved = relationship
    }

    func reveal(book: Book) {
        bookObserved = book
    }
    
    func created(books: [Book]) {
        bookObserved = books.first
    }

    func deleted(books: [Book]) {
        bookObserved = books.first
    }
    
    func testNewBook() {
        info.addObserver(self)
        XCTAssertTrue(actionManager.validate(identifier: "NewBook", info: info).enabled)
        actionManager.perform(identifier: "NewBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 1)
        XCTAssertNotNil(bookObserved)
    }
    
    func testDeleteBooks() {
        let book = Book(context: context)
        XCTAssertEqual(count(of: "Book"), 1)
        
        info[ActionContext.selectionKey] = [book]
        info.addObserver(self)

        XCTAssertTrue(actionManager.validate(identifier: "DeleteBooks", info: info).enabled)

        actionManager.perform(identifier: "DeleteBooks", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 0)
        XCTAssertEqual(bookObserved, book)

        info[ActionContext.selectionKey] = []
        XCTAssertFalse(actionManager.validate(identifier: "DeleteBooks", info: info).enabled)
        
        XCTAssertFalse(actionManager.validate(identifier: "DeleteBooks", info: ActionInfo()).enabled)
    }
    
    
    func testAddRelationship() {
        let book = Book(context: context)
        XCTAssertEqual(book.roles.count, 0)

        XCTAssertFalse(actionManager.validate(identifier: "AddRelationship", info: info).enabled)

        info.addObserver(self)
        info[ActionContext.selectionKey] = [book]
        info[PersonAction.roleKey] = "author"

        XCTAssertTrue(actionManager.validate(identifier: "AddRelationship", info: info).enabled)
        actionManager.perform(identifier: "AddRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(book.roles.first?.name, "author")

        XCTAssertNotNil(relationshipObserved)
    }
    
    func testRemoveRelationship() {
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        XCTAssertEqual(book.roles.count, 1)
        
        XCTAssertFalse(actionManager.validate(identifier: "RemoveRelationship", info: info).enabled)

        info.addObserver(self)
        info[PersonAction.relationshipKey] = relationship
        info[ActionContext.selectionKey] = [book]

        XCTAssertNotNil(relationship.managedObjectContext)

        XCTAssertTrue(actionManager.validate(identifier: "RemoveRelationship", info: info).enabled)
        actionManager.perform(identifier: "RemoveRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 0)
        
        XCTAssertNil(relationship.managedObjectContext)
    }

    func check(relationship: Relationship, book: Book, person: Person) {
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(relationship.books?.count, 1)
        XCTAssertEqual(relationship.books?.allObjects.first as? Book, book)
        XCTAssertEqual(relationship.person, person)
    }

    func testChangeRelationshipAction() {
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        check(relationship: relationship, book: book, person: person)
        
        let otherPerson = Person(context: context)
        info[PersonAction.relationshipKey] = relationship
        info[PersonAction.personKey] = otherPerson
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
        actionManager.perform(identifier: "ChangeRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(book.roles.count, 1)
        if let relationship = book.relationships?.allObjects.first as? Relationship {
            check(relationship: relationship, book: book, person: otherPerson)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(count(of: "Person"), 2)
        XCTAssertEqual(count(of: "Relationship"), 2)
        XCTAssertEqual(count(of: "Book"), 1)
    }

    func testChangeRelationshipActionNewPerson() {
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        check(relationship: relationship, book: book, person: person)
        
        info[PersonAction.relationshipKey] = relationship
        info[PersonAction.newPersonKey] = "New Person"
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
        actionManager.perform(identifier: "ChangeRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(book.roles.count, 1)
        if let relationship = book.relationships?.allObjects.first as? Relationship {
            XCTAssertEqual(relationship.person?.name, "New Person")
            check(relationship: relationship, book: book, person: relationship.person!)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(count(of: "Person"), 2)
        XCTAssertEqual(count(of: "Relationship"), 2)
        XCTAssertEqual(count(of: "Book"), 1)
    }

    func testAddPublisher() {
        let book = Book(context: context)
        XCTAssertNil(book.publisher)

        XCTAssertFalse(actionManager.validate(identifier: "AddPublisher", info: info).enabled)
        
        info.addObserver(self)
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "AddPublisher", info: info).enabled)
        actionManager.perform(identifier: "AddPublisher", info: info)
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(book.publisher)
        XCTAssertNotNil(publisherObserved)
    }
    
    func testRemovePublisher() {
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        book.publisher = publisher
        
        XCTAssertFalse(actionManager.validate(identifier: "RemovePublisher", info: info).enabled)
        
        info.addObserver(self)
        info[PublisherAction.publisherKey] = publisher
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "RemovePublisher", info: info).enabled)
        actionManager.perform(identifier: "RemovePublisher", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(publisherObserved)
        XCTAssertNil(book.publisher)
//        XCTAssertNil(publisher.managedObjectContext)
    }

    func testChangePublisherAction() {
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        book.publisher = publisher
        
        let otherPublisher = Publisher(context: context)
        info[PublisherAction.publisherKey] = otherPublisher
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "ChangePublisher", info: info).enabled)
        actionManager.perform(identifier: "ChangePublisher", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(book.publisher, otherPublisher)
    }
    
    func testChangePublisherActionNewPerson() {
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        book.publisher = publisher

        info[PublisherAction.newPublisherKey] = "New Publisher"
        info[ActionContext.selectionKey] = [book]
        
        XCTAssertTrue(actionManager.validate(identifier: "ChangePublisher", info: info).enabled)
        actionManager.perform(identifier: "ChangePublisher", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(book.publisher?.name, "New Publisher")
        XCTAssertEqual(count(of: "Publisher"), 2)
        XCTAssertEqual(count(of: "Book"), 1)
    }

    
    func testRevealBook() {
        let book = Book(context: context)
        info[ActionContext.rootKey] = self
        info[BookAction.bookKey] = book
        XCTAssertTrue(actionManager.validate(identifier: "RevealBook", info: info).enabled)

        actionManager.perform(identifier: "RevealBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(bookObserved, book)
    }
}
