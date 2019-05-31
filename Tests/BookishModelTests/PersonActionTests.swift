// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


class PersonActionTests: ModelActionTestCase, PersonViewer, PersonLifecycleObserver {
    var personObserved: Person?
    func reveal(person: Person) {
        personObserved = person
    }
    
    func created(person: Person) {
        personObserved = person
    }

    func deleted(person: Person) {
        personObserved = person
    }
    
    
    func testNewPerson() {
        XCTAssertTrue(actionManager.validate(identifier: "NewPerson", info: info).enabled)
        info.addObserver(self)
        actionManager.perform(identifier: "NewPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 1)
        XCTAssertNotNil(personObserved)
    }
    
    func testDeletePerson() {
        let person = Person(context: context)
        XCTAssertEqual(count(of: "Person"), 1)
        
        info.addObserver(self)
        info[ActionContext.selectionKey] = [person]

        XCTAssertTrue(actionManager.validate(identifier: "DeletePerson", info: info).enabled)

        actionManager.perform(identifier: "DeletePerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 0)
        XCTAssertEqual(personObserved, person)

        // empty selection should disable
        info[ActionContext.selectionKey] = []
        XCTAssertFalse(actionManager.validate(identifier: "DeletePerson", info: info).enabled)

        // selection of wrong type should disable
        info[ActionContext.selectionKey] = [Book(context: context)]
        XCTAssertFalse(actionManager.validate(identifier: "DeletePerson", info: info).enabled)

        // no context should disable
        XCTAssertFalse(actionManager.validate(identifier: "DeletePerson", info: ActionInfo()).enabled)
    }
    
    func testRevealPerson() {
        let person = Person(context: context)
        info[ActionContext.rootKey] = self
        info[PersonAction.personKey] = person

        XCTAssertTrue(actionManager.validate(identifier: "RevealPerson", info: info).enabled)
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personObserved, person)
    }
    
    func testRevealPersonFromRelationship() {
        let person = Person(context: context)
        let relationship = person.relationship(as: "Author")
        info[ActionContext.rootKey] = self
        info[PersonAction.relationshipKey] = relationship
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personObserved, person)
    }
 
    func testMergePerson() {
        bktChannel.enabled = true
        
        let book1 = Book.named("book1", in: context)
        let person1 = Person.named("test1", in: context)
        book1.addToRelationships(person1.relationship(as: "author"))

        let book2 = Book.named("book2", in: context)
        let person2 = Person.named("test2", in: context)
        book2.addToRelationships(person2.relationship(as: "author"))

        XCTAssertFalse(actionManager.validate(identifier: "MergePerson", info: info).enabled)

        info[ActionContext.selectionKey] = [person1, person2]
        
        XCTAssertEqual(context.countEntities(type: Person.self), 2)
        XCTAssertTrue(actionManager.validate(identifier: "MergePerson", info: info).enabled)
        actionManager.perform(identifier: "MergePerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(context.countEntities(type: Person.self), 1)

        let authors = person1.relationship(as: "author")
        XCTAssertEqual(authors.books?.count, 2)
    }
    
    func performSplit(name: String, expected: [String], explicit: String? = nil) {
        bktChannel.enabled = true
        
        let book1 = Book.named("book1", in: context)
        let book2 = Book.named("book2", in: context)
        let person = Person.named("test1", in: context)
        person.name = name
        let relationship = person.relationship(as: "author")
        book1.addToRelationships(relationship)
        book2.addToRelationships(relationship)
        
        
        XCTAssertEqual(context.countEntities(type: Person.self), 1)
        XCTAssertFalse(actionManager.validate(identifier: "SplitPerson", info: info).enabled)
        info[ActionContext.selectionKey] = [person]

        XCTAssertTrue(actionManager.validate(identifier: "SplitPerson", info: info).enabled)

        if let explicit = explicit {
            info[PersonAction.splitNameKey] = explicit
        }
        actionManager.perform(identifier: "SplitPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(context.countEntities(type: Person.self), 2)
        
        XCTAssertEqual(book1.relationships?.count, 2)
        XCTAssertEqual(book2.relationships?.count, 2)
        
        let people: [Person] = Person.everyEntity(in: context)
        let names = people.map { $0.name! }.sorted { $0 < $1 }
        XCTAssertEqual(names, expected)
    }
    
    func testSplitPersonFourNames() {
        performSplit(name: "A B C D", expected: ["A B", "C D"])
    }
    
    func testSplitPersonCommaInNames() {
        performSplit(name: "Foo,Bar", expected: ["Bar", "Foo"] )
    }

    func testSplitPersonExplicitName() {
        performSplit(name: "Some Complex Name Foo Bar", expected: ["Foo Bar", "Some Complex Name"], explicit: "Foo Bar" )
    }

}

