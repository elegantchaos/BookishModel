// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class SeriesDetailProviderTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series(context: context)
        let provider = series.getProvider()
        XCTAssertTrue(provider is SeriesDetailProvider)
    }

    func testStandardDetails() {
        let details = SeriesDetailProvider.standardDetails(showDebug: false)
        let debugDetails = SeriesDetailProvider.standardDetails(showDebug: true)
        XCTAssertTrue(details.count > 0)
        XCTAssertTrue(debugDetails.count > details.count)
    }
    
    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = SeriesDetailProvider()
        
        source.filter(for: [], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)

        let series = Series(context: context)
        series.name = "Test"
        series.notes = "Some notes"
        
        source.filter(for: [series], editing: false, combining: false, context: TestContext(showDebug: true))
        XCTAssertEqual(source.itemCount(for: 0), 2)
        XCTAssertEqual(source.sectionCount, 1)

        source.filter(for: [series], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 1)
        XCTAssertEqual(source.sectionCount, 1)

        let book = Book(context: context)
        book.addToSeries(series, position: 1)
        
        source.filter(for: [series], editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 2)
        XCTAssertEqual(source.info(section: 0, row: 0).kind, DetailSpec.textKind)
        XCTAssertEqual(source.info(section: 0, row: 1).kind, BookDetailItem.bookKind)
        XCTAssertEqual(source.sectionCount, 1)
    }

    func testRemoveAction() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let series = Series(context: context)
        let item = SeriesDetailItem(series: series, absolute: 0, index: 0, source: BookDetailProvider())
        if let (key, action, object) = item.removeAction {
            XCTAssertEqual(key, SeriesAction.seriesKey)
            XCTAssertEqual(action, "button.RemoveSeries")
            XCTAssertEqual(object as? Series, series)
        } else {
            XCTFail()
        }
    }
    
    func testRemoveActionNil() {
        let item = SeriesDetailItem(series: nil, absolute: 0, index: 0, source: BookDetailProvider())
        XCTAssertNil(item.removeAction)
    }
}
