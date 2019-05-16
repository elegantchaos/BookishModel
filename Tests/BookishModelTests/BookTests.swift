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
        let allBooks: [Book] = context.everyEntity()
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
        XCTAssertEqual(book.dimensions, "1.0 x 2.0 x 3.0")
    }
    
    func testAddToSeries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries?.count, 0)
        let series = Series(context: context)
        book.addToSeries(series, position: 1)
        let entries = (book.entries as? Set<SeriesEntry>)!
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(Array(entries).first?.position, 1)
        
        // adding the same series again should just update the position
        book.addToSeries(series, position: 2)
        let entries2 = (book.entries as? Set<SeriesEntry>)!
        XCTAssertEqual(entries2.count, 1)
        XCTAssertEqual(Array(entries2).first?.position, 2)
    }
    
    func testSetPosition() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries?.count, 0)
        let series = Series(context: context)
        book.addToSeries(series, position: 1)
        let entries = (book.entries as? Set<SeriesEntry>)!
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(Array(entries).first?.position, 1)
        
        book.setPosition(in: series, to: 2)
        XCTAssertEqual(Array(entries).first?.position, 2)
    }

    func testSetPositionMissing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.entries?.count, 0)
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
        XCTAssertEqual(book.entries?.count, 0)
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
}
