// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class BookTests: ModelTestCase {
    func testAllBooks() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let b1 = Book(context: context)
        let b2 = Book(context: context)
        let allBooks: [Book] = Book.everyEntity(in: context)
        XCTAssertEqual(allBooks.count, 2)
        XCTAssertTrue(allBooks.contains(b1))
        XCTAssertTrue(allBooks.contains(b2))
        
    }
    
    func testDimensions() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        book.width = 1.0
        book.height = 2.0
        book.length = 3.0
        XCTAssertEqual(book.dimensions, [1.0, 2.0, 3.0])
    }
    
    func testAddToSeries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries.count, 0)
        let series = Series(context: context)
        book.addToSeries(series, position: 1)
        XCTAssertEqual(book.entries.count, 1)
        XCTAssertEqual(book.entries.first?.position, 1)
        
        // adding the same series again should just update the position
        book.addToSeries(series, position: 2)
        XCTAssertEqual(book.entries.count, 1)
        XCTAssertEqual(book.entries.first?.position, 2)
    }
    
    func testSetPosition() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries.count, 0)
        let series = Series(context: context)
        book.addToSeries(series, position: 1)
        XCTAssertEqual(book.entries.count, 1)
        XCTAssertEqual(book.entries.first?.position, 1)
        
        book.setPosition(in: series, to: 2)
        XCTAssertEqual(book.entries.first?.position, 2)
    }

    func testSetPositionMissing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries.count, 0)
        let series = Series(context: context)
        
        #if testFatalErrors && (!os(iOS) || targetEnvironment(simulator))
        XCTAssertFatalError {
            book.setPosition(in: series, to: 2)
        }
        #endif
    }

    func testPosition() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries.count, 0)
        let series = Series(context: context)
        XCTAssertEqual(book.position(in: series), Book.notFound)

        book.addToSeries(series, position: 1)
        XCTAssertEqual(book.position(in: series), 1)
    }

    func testSectionName() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.sectionName, "U")
    }
    
    func testSortName() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        book.name = "Foo Bar"
        XCTAssertEqual(book.sortName, "Foo Bar")
    }
    
    func testIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        book.asin = "test-asin"
        book.isbn = "test-isbn"
        XCTAssertEqual(book.identifier, "test-isbn (isbn)\ntest-asin (asin)")
        
        book.asin = book.isbn
        XCTAssertEqual(book.identifier, "test-isbn (isbn/asin)")
        
        book.identifier = "blah" // setter should do nothing
        XCTAssertEqual(book.identifier, "test-isbn (isbn/asin)")
    }
    
    func testSummary() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertNil(book.summary)

        let series = Series(context: context)
        book.addToSeries(series, position: 0)

        series.name = nil
        XCTAssertNil(book.summary)

        series.name = "Series"
        XCTAssertEqual(book.summary, "Series")
        
        book.addToSeries(series, position: 2)
        XCTAssertEqual(book.summary, "Series, Book 2")


        book.subtitle = "Test"
        XCTAssertEqual(book.summary, "Test")

    }
    
    func testSummaryItems() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.summaryItems(mode: .person), [])
        XCTAssertEqual(book.summaryItems(mode: .publisher), [])
        XCTAssertEqual(book.summaryItems(mode: .series), [])

        let series = Series.named("Test Series", in: context)
        book.addToSeries(series, position: 2)
        book.publisher = Publisher.named("Test Publisher", in: context)
        book.published = Date(timeIntervalSince1970: 0)
        let person = Person.named("Test Person", in: context)
        let _ = book.addRelationship(with: person, as: Role.named(.author, in: context))
        
        XCTAssertEqual(book.summaryItems(mode: .person), ["1970", "Test Publisher"])
        XCTAssertEqual(book.summaryItems(mode: .publisher), ["Test Person", "1970"])
        XCTAssertEqual(book.summaryItems(mode: .series), ["Test Person", "1970", "Test Publisher"])
    }
    
    func testAddRelationship() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let person = Person(context: context)
        let role = Role.named(Role.StandardName.author, in: context)
        let relationship = book.addRelationship(with: person, as: role)
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(relationship.person, person)
        XCTAssertTrue(relationship.contains(book: book))
        
        let another = book.addRelationship(with: person, as: role)
        XCTAssertTrue(relationship === another)
    }
    
    func testRemoveRelationship() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.StandardName.author)
        book.addToRelationships(relationship)
        XCTAssertEqual(book.roles.count, 1)

        book.removeRelationship(relationship)
        XCTAssertEqual(book.roles.count, 0)
        XCTAssertTrue(relationship.isDeleted)
    }
    
    func testExistingRelationship() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let person = Person(context: context)
        let role = Role.named(Role.StandardName.author, in: context)
        let relationship = person.relationship(as: role)
        book.addToRelationships(relationship)
        XCTAssertEqual(book.roles.count, 1)

        let existing = book.existingRelationship(with: person, as: role)
        XCTAssertEqual(existing, relationship)
        
        let nonExistant = book.existingRelationship(with: person, as: Role.named(Role.StandardName.editor, in: context))
        XCTAssertNil(nonExistant)
    }
}
