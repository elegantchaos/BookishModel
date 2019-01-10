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
        XCTAssertEqual(source.rows, 1)
        
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.addToBooks(book)

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 2)

        let relationship2 = person.relationship(as: "editor")
        relationship2.addToBooks(book)

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 3)

        book.publisher = Publisher(context: context)
        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 4)
        
        let series = Series(context: context)
        let entry = Entry(context: context)
        entry.series = series
        entry.index = 1
        book.series = entry

        source.filter(for: [book], editing: false)
        XCTAssertEqual(source.rows, 5)

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
        let entry = Entry(context: context)
        entry.series = series
        entry.index = 1
        book.series = entry
        
        source.filter(for: [book], editing: false)
        let personRow = source.info(for: 0, editing: false)
        XCTAssertEqual(personRow.category, .person)
        XCTAssertEqual(personRow.absolute, 0)
        XCTAssertEqual(personRow.index, 0)

        let editablePersonRow = source.info(for: 0, editing: true)
        XCTAssertEqual(editablePersonRow.category, .person)
        XCTAssertEqual(editablePersonRow.kind, .editablePerson)

        let publisherRow = source.info(for: 1, editing: false)
        XCTAssertEqual(publisherRow.category, .publisher)
        XCTAssertEqual(publisherRow.absolute, 1)
        XCTAssertEqual(publisherRow.index, 0)

        let seriesRow = source.info(for: 2, editing: false)
        XCTAssertEqual(seriesRow.category, .series)
        XCTAssertEqual(seriesRow.absolute, 2)
        XCTAssertEqual(seriesRow.index, 0)

        let detailRow = source.info(for: 3, editing: false)
        XCTAssertEqual(detailRow.category, .detail)
        XCTAssertEqual(detailRow.absolute, 3)
        XCTAssertEqual(detailRow.index, 0)

        let editableDetailRow = source.info(for: 3, editing: true)
        XCTAssertEqual(editableDetailRow.category, .detail)
        XCTAssertEqual(editableDetailRow.kind, .hidden)
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
        let personRow = source.info(for: 0, editing: false)
        XCTAssertEqual(personRow.category, .person)
        
        let rowRelationship = source.person(for: personRow)
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
        let row1 = source.info(for: 0, editing: false)
        XCTAssertEqual(source.person(for: row1), relationship2)
        let row2 = source.info(for: 1, editing: false)
        XCTAssertEqual(source.person(for: row2), relationship1)
        
        XCTAssertEqual(source.heading(for: row1), "author")
        XCTAssertEqual(source.heading(for: row2), "author")
    }
    
    func testPublisherSorting() {
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
        let row1 = source.info(for: 0, editing: false)
        XCTAssertEqual(source.publisher(for: row1), publisher2)
        let row2 = source.info(for: 1, editing: false)
        XCTAssertEqual(source.publisher(for: row2), publisher1)

        XCTAssertEqual(source.heading(for: row1), DetailDataSource.publisherHeading)
        XCTAssertEqual(source.heading(for: row2), DetailDataSource.publisherHeading)
    }
    
    func testSeriesAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        let series = Series(context: context)
        let entry = Entry(context: context)
        entry.book = book
        entry.series = series
        
        source.filter(for: [book], editing: false)
        let row = source.info(for: 0, editing: false)
        XCTAssertEqual(source.series(for: row), entry)

        XCTAssertEqual(source.heading(for: row), DetailDataSource.seriesHeading)
    }
    
    func testDetailAccess() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        book.asin = "blah"
        
        source.filter(for: [book], editing: false)
        let row = source.info(for: 0, editing: false)
        let detail = source.details(for: row)
        XCTAssertEqual(detail.binding, "identifier")
        XCTAssertEqual(source.heading(for: row), "Identifier")
    }

    func testDetailAccessEditing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let book = Book(context: context)
        
        source.filter(for: [book], editing: true)
        let row = source.info(for: 0, editing: true)
        let detail = source.details(for: row)
        XCTAssertEqual(detail.binding, "notes")
        XCTAssertEqual(source.heading(for: row), "Notes")
    }

    func testInsertRelationship()
    {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = DetailDataSource()
        let relationship = Relationship(context: context)
        XCTAssertEqual(source.insert(relationship: relationship), 0)
        XCTAssertEqual(source.remove(relationship: relationship), 0)
        XCTAssertNil(source.remove(relationship: relationship))
    }
}
