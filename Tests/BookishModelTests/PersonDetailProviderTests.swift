// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PersonDetailProviderTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let provider = person.getProvider()
        XCTAssertTrue(provider is PersonDetailProvider)
    }

    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = PersonDetailProvider()
        
        source.filter(for: [], editing: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)
        
        let person = Person(context: context)
        person.name = "Test"
        person.notes = "Some notes"
        
        source.filter(for: [person], editing: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)

        let book = Book(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)
        
        source.filter(for: [person], editing: false, context: TestContext())
        XCTAssertEqual(source.sectionCount, 2)
        XCTAssertEqual(source.itemCount(for: 1), 1)
    }

}
