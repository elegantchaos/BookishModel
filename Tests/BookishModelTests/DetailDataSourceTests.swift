// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class DetailDataSourceTests: ModelTestCase {
    func testDetailSpecDefaults() {
        let spec = DetailSpec(binding: "test")
        XCTAssertEqual(spec.binding, "test")
        XCTAssertEqual(spec.label, "Test")
        XCTAssertEqual(spec.kind, .text)
        XCTAssertEqual(spec.editableKind, .text)
    }

    func testDetailSpecExplicitLabel() {
        let spec = DetailSpec(binding: "test", label: "explicit")
        XCTAssertEqual(spec.binding, "test")
        XCTAssertEqual(spec.label, "explicit")
    }

    func testDetailSpecExplicitViewKind() {
        let spec = DetailSpec(binding: "test", viewAs: .date)
        XCTAssertEqual(spec.kind, .date)
        XCTAssertEqual(spec.editableKind, .date)
    }

    func testDetailSpecExplicitEditKind() {
        let spec = DetailSpec(binding: "test", viewAs: .date, editAs: .editableDate)
        XCTAssertEqual(spec.kind, .date)
        XCTAssertEqual(spec.editableKind, .editableDate)
    }

    func testStandardDetails() {
        let details = DetailSpec.standardDetails
        XCTAssertTrue(details.count > 0)
    }
    
    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()

        source.filter(for: [], editing: false)
        XCTAssertEqual(source.rows, 0)

//        source.filter(for: [], editing: true)
//        XCTAssertEqual(source.rows, DetailSpec.standardDetails.count)

        let book = Book(context: context)
        book.isbn = "12343"
        book.asin = "blah"
        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 2)
        
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 3)

        let relationship2 = person.relationship(as: "editor")
        relationship2.addToBooks(book)

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 4)

        book.publisher = Publisher(context: context)
        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 5)
        
        let series = Series(context: context)
        let entry = SeriesEntry(context: context)
        entry.series = series
        entry.position = 1
        book.addToEntries(entry)

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 6)

    }
    
    func testRowInfo() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
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
        
        source.filter(for: [book], editing: false)
        let personRow = source.info(for: 0)
        XCTAssertEqual(personRow.category, .person)
        XCTAssertEqual(personRow.absolute, 0)
        XCTAssertEqual(personRow.index, 0)

        let publisherRow = source.info(for: 1)
        XCTAssertEqual(publisherRow.category, .publisher)
        XCTAssertEqual(publisherRow.absolute, 1)
        XCTAssertEqual(publisherRow.index, 0)

        let seriesRow = source.info(for: 2)
        XCTAssertEqual(seriesRow.category, .series)
        XCTAssertEqual(seriesRow.absolute, 2)
        XCTAssertEqual(seriesRow.index, 0)

        let detailRow = source.info(for: 3)
        XCTAssertEqual(detailRow.category, .detail)
        XCTAssertEqual(detailRow.absolute, 3)
        XCTAssertEqual(detailRow.index, 0)

        source.filter(for: [book], editing: true)

        let editablePersonRow = source.info(for: 1)
        XCTAssertEqual(editablePersonRow.category, .person)
        XCTAssertEqual(editablePersonRow.kind, .person)
        XCTAssertTrue(editablePersonRow.placeholder)
        
        let editableSeriesRow = source.info(for: 4)
        XCTAssertEqual(editableSeriesRow.category, .series)
        XCTAssertEqual(editableSeriesRow.kind, .series)
        XCTAssertTrue(editableSeriesRow.placeholder)
    }
    
    func testCommonPerson() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let person = Person(context: context)
        person.name = "Test"
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book1)
        relationship.addToBooks(book2)

        source.filter(for: [book1, book2], editing: false)
        let personRow = source.info(for: 0)
        XCTAssertEqual(personRow.category, .person)
        
        let rowRelationship = source.relationship(for: personRow)
        XCTAssertEqual(relationship, rowRelationship)
    }
    
    func testPersonSorting() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        let person1 = Person(context: context)
        person1.name = "Z"
        let person2 = Person(context: context)
        person2.name = "A"
        let relationship1 = person1.relationship(as: "author")
        relationship1.addToBooks(book)
        let relationship2 = person2.relationship(as: "author")
        relationship2.addToBooks(book)
        
        source.filter(for: [book], editing: false)
        let row1 = source.info(for: 0)
        XCTAssertEqual(source.relationship(for: row1), relationship2)
        let row2 = source.info(for: 1)
        XCTAssertEqual(source.relationship(for: row2), relationship1)
        
        XCTAssertEqual(source.heading(for: row1), "author")
        XCTAssertEqual(source.heading(for: row2), "author")
    }
    
    func testSamePublishers() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let publisher1 = Publisher(context: context)
        publisher1.name = "Z"
        book1.publisher = publisher1
        book2.publisher = publisher1
        
        source.filter(for: [book1, book2], editing: false)
        let row = source.info(for: 0)
        XCTAssertEqual(source.publisher(for: row), publisher1)

        let heading = DetailDataSource.publisherHeading.lowercased()
        XCTAssertEqual(source.heading(for: row), heading)
    }
  
    func testDifferentPublishers() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book1 = Book(context: context)
        let book2 = Book(context: context)
        let publisher1 = Publisher(context: context)
        publisher1.name = "Z"
        let publisher2 = Publisher(context: context)
        publisher2.name = "A"
        book1.publisher = publisher1
        book2.publisher = publisher2

        source.filter(for: [book1, book2], editing: false)
        let row = source.info(for: 0)
        XCTAssertEqual(row.category, .detail)
    }

    func testSeriesAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        let series = Series(context: context)
        let entry = SeriesEntry(context: context)
        entry.book = book
        entry.series = series
        
        source.filter(for: [book], editing: false)
        let row = source.info(for: 0)
        XCTAssertEqual(source.series(for: row), series)

        XCTAssertEqual(source.heading(for: row), DetailDataSource.seriesHeading.lowercased())
    }
    
    func testDetailAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        book.asin = "blah"
        
        source.filter(for: [book], editing: false)
        let row = source.info(for: 0)
        let detail = source.details(for: row)
        XCTAssertEqual(detail.binding, "identifier")
        XCTAssertEqual(source.heading(for: row), "identifier")
    }

    func testDetailAccessEditing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        
        source.filter(for: [book], editing: true)
        let row = source.info(for: 3)
        let detail = source.details(for: row)
        XCTAssertEqual(detail.binding, "notes")
        XCTAssertEqual(source.heading(for: row), "notes")
    }

    func testInsertRelationship()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        source.filter(for: [book], editing: false)
        let relationship = Relationship(context: context)
        XCTAssertEqual(source.insert(relationship: relationship), 0)
        XCTAssertEqual(source.remove(relationship: relationship), 0)
        XCTAssertNil(source.remove(relationship: relationship))
    }
    
    func testInsertPublisher()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        source.filter(for: [book], editing: false)
        let publisher = Publisher(context: context)
        XCTAssertEqual(source.insert(publisher: publisher), 0)
        XCTAssertEqual(source.remove(publisher: publisher), 0)
        XCTAssertNil(source.remove(publisher: publisher))
    }

    func testInsertSeries()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        source.filter(for: [book], editing: false)
        let series = Series(context: context)
        XCTAssertEqual(source.insert(series: series), 0)
        XCTAssertEqual(source.remove(series: series), 0)
        XCTAssertNil(source.remove(series: series))
    }

}
