// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class RelationshipTests: ModelTestCase {

    func testRelationshipIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.role?.uuid = "author"
        person.uuid = "person"
        XCTAssertEqual(relationship.uniqueIdentifier, "person-author" as NSString)
    }
    
    func testRelationshipMissingIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.role?.uuid = nil
        person.uuid = nil
        XCTAssertEqual(relationship.uniqueIdentifier, ModelObject.missingUUID)
    }
//
//    func testDescription() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//
//        let book = Book.named("test", in: context)
//        book.uuid = "book-id"
//
//        let person = Person.named("test", in: context)
//        person.uuid = "person-id"
//        
//        let relationship = Relationship(in: context)
//        XCTAssertEqual(relationship.description, "<Relationship: <unknown> for <unknown>>")
//        
//        relationship.role = Role.named("author", in: context)
//        XCTAssertEqual(relationship.description, "<Relationship: author for <unknown>>")
//
//        relationship.person = person
//        XCTAssertEqual(relationship.description, "<Relationship: author for test (person-id)>")
//
//        book.addToRelationships(relationship)
//        XCTAssertEqual(relationship.description, "<Relationship: author for test (person-id) with test (book-id)>")
//    }
//    
//    func testContains() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let book = Book.named("test", in: context)
//        let relationship = Relationship(in: context)
//        
//        XCTAssertFalse(relationship.contains(book: book))
//
//        let person = Person.named("test", in: context)
//        relationship.person = person
//        relationship.add(book)
//        XCTAssertTrue(relationship.contains(book: book))
//    }
}
