// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class SeriesTests: ModelTestCase {
    func testAllSeries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let b = Book(context: context)
        let s1 = Series(context: context)
        let e1 = SeriesEntry(context: context)
        e1.book = b
        e1.series = s1
        let s2 = Series(context: context)
        let allSeries: [Series] = Series.everyEntity(in: context)
        XCTAssertEqual(allSeries.count, 2)
        XCTAssertTrue(allSeries.contains(s1))
        XCTAssertTrue(allSeries.contains(s2))
    }

    func testAllEntries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let e1 = SeriesEntry(context: context)
        let e2 = SeriesEntry(context: context)
        let allEntries: [SeriesEntry] = SeriesEntry.everyEntity(in: context)
        XCTAssertEqual(allEntries.count, 2)
        XCTAssertTrue(allEntries.contains(e1))
        XCTAssertTrue(allEntries.contains(e2))
    }

    func testNamedExists() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series(context: context)
        series.name = "test"
        
        let found = Series.named("test", in: context)
        XCTAssertEqual(found.name, "test")
    }

    func testNamedMissing() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series.named("test", in: context, createIfMissing: false)
        XCTAssertNil(series)
    }

    func testNamedCreate() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series.named("test", in: context, createIfMissing: true)
        XCTAssertEqual(series?.name, "test")
    }

    func testCategoryLabel() {
        XCTAssertEqual(Series.entityLabel, "Series.label")
    }
    
    func testSeriesEntryIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let series = Series(context: context)
        let entry = book.addToSeries(series, position: 1)
        book.uuid = "book"
        series.uuid = "series"
        XCTAssertEqual(entry.uniqueIdentifier, "book-series" as NSString)
    }
    
    func testSeriesEntryMissingIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let series = Series(context: context)
        let entry = book.addToSeries(series, position: 1)
        book.uuid = nil
        series.uuid = nil
        XCTAssertEqual(entry.uniqueIdentifier, ModelObject.missingUUID)
    }
    
    func testDescription() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let entry = SeriesEntry(in: context)
        XCTAssertEqual(entry.description, "<Entry: <unknown> #0 in <unknown>>")
        
        let series = Series.named("test", in: context)
        series.uuid = "series-id"
        entry.series = series
        XCTAssertEqual(entry.description, "<Entry: <unknown> #0 in test (series-id)>")
        
        let book = Book.named("test", in: context)
        book.uuid = "book-id"
        entry.book = book
        XCTAssertEqual(entry.description, "<Entry: test (book-id) #0 in test (series-id)>")
    }
    
    func testSectionName() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series(context: context)
        series.name = "TeSt NaMe"
        XCTAssertEqual(series.sectionName, "T")
    }
}
