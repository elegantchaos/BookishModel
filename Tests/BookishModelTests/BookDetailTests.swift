// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class TestContext: DetailContext {
    var bookSorting: [NSSortDescriptor] = []
    var relationshipSorting: [NSSortDescriptor] = []
    var entrySorting: [NSSortDescriptor] = []
    var showDebug: Bool = false
}

class BookDetailTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let provider = book.getProvider()
        XCTAssertTrue(provider is BookDetailProvider)
    }
    
    func testDetailSpecDefaults() {
        let spec = DetailSpec(binding: "test")
        XCTAssertEqual(spec.binding, "test")
        XCTAssertEqual(spec.kind, DetailSpec.textKind)
        XCTAssertEqual(spec.editableKind, DetailSpec.textKind)
    }

    func testDetailSpecExplicitViewKind() {
        let spec = DetailSpec(binding: "test", viewAs: DetailSpec.dateKind)
        XCTAssertEqual(spec.kind, DetailSpec.dateKind)
        XCTAssertEqual(spec.editableKind, DetailSpec.dateKind)
    }

    func testDetailSpecExplicitEditKind() {
        let spec = DetailSpec(binding: "test", viewAs: DetailSpec.dateKind, editAs: DetailSpec.editableDateKind)
        XCTAssertEqual(spec.kind, DetailSpec.dateKind)
        XCTAssertEqual(spec.editableKind, DetailSpec.editableDateKind)
    }

    func testStandardDetails() {
        let details = BookDetailProvider.standardDetails(showDebug: false)
        let debugDetails = BookDetailProvider.standardDetails(showDebug: true)
        XCTAssertTrue(details.count > 0)
        XCTAssertTrue(debugDetails.count > details.count)
    }
    
    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()

        source.filter(for: [], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)

        let book = Book(context: context)
        book.isbn = "12343"
        book.asin = "blah"
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 3)
        
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)

        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 4)

        let relationship2 = person.relationship(as: "editor")
        relationship2.addToBooks(book)

        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 5)

        book.publisher = Publisher(context: context)
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 6)
        
        let series = Series(context: context)
        let entry = SeriesEntry(context: context)
        entry.series = series
        entry.position = 1
        book.addToEntries(entry)

        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 7)

    }
    
    func testRowInfo() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        book.isbn = "12343"
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)
        book.publisher = Publisher(context: context)
        let series = Series(context: context)
        let entry = SeriesEntry(context: context)
        entry.series = series
        entry.position = 1
        book.addToEntries(entry)
        
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let personRow = source.info(section: 0, row: 0)
        XCTAssertTrue(personRow is PersonDetailItem)
        XCTAssertEqual(personRow.absolute, 0)
        XCTAssertEqual(personRow.index, 0)

        let publisherRow = source.info(section: 0, row: 1)
        XCTAssertTrue(publisherRow is PublisherDetailItem)
        XCTAssertEqual(publisherRow.absolute, 1)
        XCTAssertEqual(publisherRow.index, 0)

        let seriesRow = source.info(section: 0, row: 2)
        XCTAssertTrue(seriesRow is SeriesDetailItem)
        XCTAssertEqual(seriesRow.absolute, 2)
        XCTAssertEqual(seriesRow.index, 0)

        let detailRow = source.info(section: 0, row: 3)
        XCTAssertTrue(detailRow is SimpleDetailItem)
        XCTAssertEqual(detailRow.absolute, 3)
        XCTAssertEqual(detailRow.index, 0)

        source.filter(for: [book], editing: true, combining: false, context: TestContext())

        let editablePersonRow = source.info(section: 0, row: 1)
        XCTAssertTrue(editablePersonRow is PersonDetailItem)
        XCTAssertEqual(editablePersonRow.kind, "person")
        XCTAssertTrue(editablePersonRow.placeholder)
        
        let editableSeriesRow = source.info(section: 0, row: 4)
        XCTAssertTrue(editableSeriesRow is SeriesDetailItem)
        XCTAssertEqual(editableSeriesRow.kind, "series")
        XCTAssertTrue(editableSeriesRow.placeholder)
    }
    
    func testCommonPerson() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let person = Person(context: context)
        person.name = "Test"
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book1)
        relationship.addToBooks(book2)

        source.filter(for: [book1, book2], editing: false, combining: false, context: TestContext())
        let personRow = source.info(section: 0, row: 0) as? PersonDetailItem
        XCTAssertNotNil(personRow)
        
        XCTAssertEqual(relationship, personRow!.relationship)
    }
    
    func testPersonSorting() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        let person1 = Person(context: context)
        person1.name = "Z"
        let person2 = Person(context: context)
        person2.name = "A"
        let relationship1 = person1.relationship(as: "author")
        relationship1.addToBooks(book)
        let relationship2 = person2.relationship(as: "author")
        relationship2.addToBooks(book)
        
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let row1 = source.info(section: 0, row: 0) as? PersonDetailItem
        XCTAssertEqual(row1!.relationship, relationship2)
        let row2 = source.info(section: 0, row: 1) as? PersonDetailItem
        XCTAssertEqual(row2!.relationship, relationship1)
        
        XCTAssertEqual(row1?.heading, "author")
        XCTAssertEqual(row2?.heading, "author")
    }
    
    func testSamePublishers() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let publisher1 = Publisher(context: context)
        publisher1.name = "Z"
        book1.publisher = publisher1
        book2.publisher = publisher1
        
        source.filter(for: [book1, book2], editing: false, combining: false, context: TestContext())
        let row = source.info(section: 0, row: 0) as? PublisherDetailItem
        XCTAssertEqual(row!.publisher, publisher1)
        XCTAssertEqual(row?.heading, "Publisher.label")
    }
  
    func testDifferentPublishers() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let publisher1 = Publisher(context: context)
        publisher1.name = "Z"
        let publisher2 = Publisher(context: context)
        publisher2.name = "A"
        book1.publisher = publisher1
        book2.publisher = publisher2

        source.filter(for: [book1, book2], editing: false, combining: false, context: TestContext())
        let row = source.info(section: 0, row: 0)
        XCTAssertTrue(row is SimpleDetailItem)
    }

    func testSeriesAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        let series = Series(context: context)
        let entry = SeriesEntry(context: context)
        entry.book = book
        entry.series = series
        
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let row = source.info(section: 0, row: 0) as? SeriesDetailItem
        XCTAssertEqual(row!.series, series)
        
        XCTAssertEqual(row?.heading, "Series.label")
    }
    
    func testDetailAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        book.asin = "blah"
        
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let row = source.info(section: 0, row: 0) as? SimpleDetailItem
        XCTAssertEqual(row!.spec.binding, "identifier")
        XCTAssertEqual(row!.heading, "detail.identifier.label")
    }

    func testDetailAccessEditing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        
        source.filter(for: [book], editing: true, combining: false, context: TestContext())
        let row = source.info(section: 0, row: 3) as? SimpleDetailItem
        XCTAssertEqual(row?.spec.binding, "notes")
        XCTAssertEqual(row?.heading, "detail.notes.label")
    }

    func testInsertRelationship()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let relationship = Relationship(context: context)
        let relationship2 = Relationship(context: context)
        XCTAssertEqual(source.inserted(details: [relationship]).first, 0)
        XCTAssertEqual(source.updated(details: [relationship], with: [relationship2]).first, 0)
        XCTAssertEqual(source.removed(details: [relationship2]).first, 0)
        XCTAssertEqual(source.removed(details: [relationship2]).count, 0)
    }
    
    func testInsertPublisher()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let publisher = Publisher(context: context)
        XCTAssertEqual(source.inserted(details: [publisher]).first, 0)
        XCTAssertEqual(source.removed(details: [publisher]).first, 0)
        XCTAssertEqual(source.removed(details: [publisher]).count, 0)
    }

    func testInsertSeries()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = BookDetailProvider()
        let book = Book(context: context)
        source.filter(for: [book], editing: false, combining: false, context: TestContext())
        let series = Series(context: context)
        XCTAssertEqual(source.inserted(details: [series]).first, 0)
        XCTAssertEqual(source.removed(details: [series]).first, 0)
        XCTAssertEqual(source.removed(details: [series]).count, 0)
    }

}
