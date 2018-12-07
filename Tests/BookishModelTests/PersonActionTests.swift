// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


class PersonActionTests: ModelActionTestCase, PersonViewer {
    var personRevealed: Person?

    func reveal(person: Person) {
        personRevealed = person
    }
    
    func created(person: Person) {
        expectation.fulfill()
    }

    func testNewPerson() {
        actionManager.perform(identifier: "NewPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 1)
    }
    
    func testDeletePeople() {
        let person = Person(context: context)
        XCTAssertEqual(count(of: "Person"), 1)
        
        info[ActionContext.selectionKey] = [person]
        
        actionManager.perform(identifier: "DeletePeople", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 0)
    }
    
    func testRevealPerson() {
        let person = Person(context: context)
        info[ActionContext.rootKey] = self
        info[PersonAction.personKey] = person
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personRevealed, person)
    }
    
    func testRevealPersonFromRelationship() {
        let person = Person(context: context)
        let relationship = person.relationship(as: "Author")
        info[ActionContext.rootKey] = self
        info[PersonAction.relationshipKey] = relationship
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personRevealed, person)
    }
    
    func testAddRelationship() {
        let book = Book(context: context)
        XCTAssertEqual(book.roles.count, 0)
        info[ActionContext.selectionKey] = [book]
        info[PersonAction.roleKey] = "author"
        actionManager.perform(identifier: "AddRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(book.roles.first?.name, "author")
    }
    
    func testRemoveRelationship() {
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        XCTAssertEqual(book.roles.count, 1)
        
        info[PersonAction.relationshipKey] = relationship
        info[ActionContext.selectionKey] = [book]
        actionManager.perform(identifier: "RemoveRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 0)
    }
    
    func testChangeRelationshipAction() {
        func check(relationship: Relationship, book: Book, person: Person) {
            XCTAssertEqual(book.roles.count, 1)
            XCTAssertEqual(relationship.books?.count, 1)
            XCTAssertEqual(relationship.books?.allObjects.first as? Book, book)
            XCTAssertEqual(relationship.person, person)
        }
        
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        check(relationship: relationship, book: book, person: person)
        
        let otherPerson = Person(context: context)
        info[PersonAction.relationshipKey] = relationship
        info[PersonAction.personKey] = otherPerson
        info[ActionContext.selectionKey] = [book]
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

    
}

