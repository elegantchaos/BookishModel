// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class TagTests: ModelTestCase {
//    func testAllTags() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let b1 = Tag(context: context)
//        let b2 = Tag(context: context)
//        let allTags = Tag.everyEntity(in: context)
//        XCTAssertEqual(allTags.count, 2)
//        XCTAssertTrue(allTags.contains(b1))
//        XCTAssertTrue(allTags.contains(b2))
//        
//    }
    
    func testAddToSeries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let tag = Tag(context: context)
        let series = Series(context: context)
        tag.addToSeries(series)
        let tags = (series.tags as? Set<Tag>)!
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(Array(tags).first, tag)
        
        // adding the same tag again shouldn't do anything
        tag.addToSeries(series)
        XCTAssertEqual(series.tags?.count, 1)
    }
    
    func testGenericAdd() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let tag = Tag(context: context)
        let series = Series(context: context)
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        let person = Person(context: context)
        tag.add(to: [series])
        XCTAssertEqual(tag.series?.count, 1)
        tag.add(to: [person])
        XCTAssertEqual(tag.people?.count, 1)
        tag.add(to: [book])
        XCTAssertEqual(tag.books?.count, 1)
        tag.add(to: [publisher])
        XCTAssertEqual(tag.publishers?.count, 1)
    }

    func testGenericAddMixed() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let tag = Tag(context: context)
        let series = Series(context: context)
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        let person = Person(context: context)
        tag.add(to: [series, book, person, publisher])
        XCTAssertEqual(tag.people?.count, 1)
        XCTAssertEqual(tag.books?.count, 1)
        XCTAssertEqual(tag.series?.count, 1)
        XCTAssertEqual(tag.publishers?.count, 1)
    }
    
    func testGenericRemove() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let tag = Tag(context: context)
        let series = Series(context: context)
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        let person = Person(context: context)
        tag.add(to: [series, book, person, publisher])

        tag.remove(from: [series])
        XCTAssertEqual(tag.series?.count, 0)
        
        tag.remove(from: [person])
        XCTAssertEqual(tag.people?.count, 0)
        
        tag.remove(from: [book])
        XCTAssertEqual(tag.books?.count, 0)
        
        tag.remove(from: [publisher])
        XCTAssertEqual(tag.publishers?.count, 0)
    }
    
    func testGenericRemoveMixed() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let tag = Tag(context: context)
        let series = Series(context: context)
        let book = Book(context: context)
        let publisher = Publisher(context: context)
        let person = Person(context: context)
        tag.add(to: [series, book, person, publisher])
        tag.remove(from: [series, book, person, publisher])
        XCTAssertEqual(tag.people?.count, 0)
        XCTAssertEqual(tag.books?.count, 0)
        XCTAssertEqual(tag.series?.count, 0)
        XCTAssertEqual(tag.publishers?.count, 0)
    }
    
//    func testSectionName() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let tag = Tag(context: context)
//        XCTAssertEqual(tag.sectionName, "U")
//    }
//
//    func testSortName() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let tag = Tag(context: context)
//        tag.name = "Foo Bar"
//        XCTAssertEqual(tag.sortName, "Foo Bar")
//    }
//
//    func testIdentifier() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let tag = Tag(context: context)
//        tag.asin = "test-asin"
//        tag.isbn = "test-isbn"
//        XCTAssertEqual(tag.identifier, "test-isbn (isbn)\ntest-asin (asin)")
//
//        tag.asin = tag.isbn
//        XCTAssertEqual(tag.identifier, "test-isbn (isbn/asin)")
//
//        tag.identifier = "blah" // setter should do nothing
//        XCTAssertEqual(tag.identifier, "test-isbn (isbn/asin)")
//    }
}
