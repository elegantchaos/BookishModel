// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PersonDetailProviderTests: ModelTestCase {
    var container: CollectionContainer!
    var context: NSManagedObjectContext!
    var person: Person!
    
    func makeTestProvider() -> DetailProvider {
        container = makeTestContainer()
        context = container.managedObjectContext
        person = Person(context: context)
        let provider = person.getProvider()
        return provider
    }
    
    func testProvider() {
        let provider = makeTestProvider()
        XCTAssertTrue(provider is PersonDetailProvider)
    }

    func testStandardDetails() {
        let details = PersonDetailProvider.standardDetails(showDebug: false)
        let debugDetails = PersonDetailProvider.standardDetails(showDebug: true)
        XCTAssertTrue(details.count > 0)
        XCTAssertTrue(debugDetails.count > details.count)
    }
    
    func testRowCount() {
        let provider = makeTestProvider()
        provider.filter(for: [], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(provider.itemCount(for: 0), 0)
        XCTAssertEqual(provider.sectionCount, 1)
        
        person.name = "Test"
        person.notes = "Some notes"
        
        provider.filter(for: [person], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(provider.itemCount(for: 0), 1)
        XCTAssertEqual(provider.sectionCount, 1)

        provider.filter(for: [person], editing: false, combining: false, context: TestContext(showDebug: true))
        XCTAssertEqual(provider.itemCount(for: 0), 2)
        XCTAssertEqual(provider.sectionCount, 1)

        let book = Book(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)
        
        provider.filter(for: [person], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(provider.sectionCount, 2)
        XCTAssertEqual(provider.itemCount(for: 1), 1)
    }

    func testSectionTitle() {
        let provider = makeTestProvider()
        
        let book = Book(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)
        
        provider.filter(for: [person], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(provider.sectionTitle(for: 0), "")
        XCTAssertEqual(provider.sectionTitle(for: 1), "Role.section")
    }
    
    func testInfo() {
        let provider = makeTestProvider()
        
        let book = Book(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)
        
        provider.filter(for: [person], editing: false, combining: false, context: TestContext())
//        let info1 = provider.info(section: 0, row: 0)
//        XCTAssertTrue(info1 is SimpleDetailItem)

        let info2 = provider.info(section: 1, row: 0)
        XCTAssertTrue(info2 is BookDetailItem)
    }
    
    func testRemoveAction() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let relationship = Relationship(context: context)
        let item = RelationshipDetailItem(relationship: relationship, absolute: 0, index: 0, source: BookDetailProvider())
        if let (key, action, object) = item.removeAction {
            XCTAssertEqual(key, PersonAction.relationshipKey)
            XCTAssertEqual(action, "button.RemoveRelationship")
            XCTAssertEqual(object as? Relationship, relationship)
        } else {
            XCTFail()
        }
    }

    func testRemoveActionNil() {
        let item = RelationshipDetailItem(relationship: nil, absolute: 0, index: 0, source: BookDetailProvider())
        XCTAssertNil(item.removeAction)
    }

}
