// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class SeriesDetailProviderTests: ModelTestCase {
//    func testProvider() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let series = Series(context: context)
//        let provider = series.getProvider()
//        XCTAssertTrue(provider is SeriesDetailProvider)
//    }
//
//    func testStandardDetails() {
//        let details = SeriesDetailProvider.standardDetails(showDebug: false)
//        let debugDetails = SeriesDetailProvider.standardDetails(showDebug: true)
//        XCTAssertTrue(details.count > 0)
//        XCTAssertTrue(debugDetails.count > details.count)
//    }
//    
//    func testRowCount() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let source = SeriesDetailProvider()
//        
//        source.filter(for: ModelSelection([]), editing: false, combining: false, session: TestContext())
//        XCTAssertEqual(source.itemCount(for: 0), 0)
//        XCTAssertEqual(source.sectionCount, 2)
//
//        let series = Series(context: context)
//        series.name = "Test"
//        series.notes = "Some notes"
//        
//        source.filter(for: ModelSelection([series]), editing: false, combining: false, session: TestContext(showDebug: true))
//        XCTAssertEqual(source.itemCount(for: 0), 5)
//        XCTAssertEqual(source.itemCount(for: 1), 0)
//        XCTAssertEqual(source.sectionCount, 2)
//
//        source.filter(for: ModelSelection([series]), editing: false, combining: false, session: TestContext())
//        XCTAssertEqual(source.itemCount(for: 0), 4)
//        XCTAssertEqual(source.itemCount(for: 1), 0)
//        XCTAssertEqual(source.sectionCount, 2)
//
//        let book = Book(context: context)
//        book.addToSeries(series, position: 1)
//        
//        source.filter(for: ModelSelection([series]), editing: false, combining: false, session: TestContext())
//        XCTAssertEqual(source.itemCount(for: 0), 4)
//        XCTAssertEqual(source.itemCount(for: 1), 1)
//        XCTAssertEqual(source.info(section: 0, row: 0).kind, DetailSpec.paragraphKind)
//        XCTAssertEqual(source.info(section: 0, row: 1).kind, DetailSpec.numberKind)
//        XCTAssertEqual(source.info(section: 0, row: 2).kind, DetailSpec.timeKind)
//        XCTAssertEqual(source.sectionCount, 2)
//    }
//
////    func testRemoveAction() {
////        let container = makeTestContainer()
////        let context = container.managedObjectContext
////        let series = Series(context: context)
////        let book = Book.named("test", in: context)
////        let entry = book.addToSeries(series, position: 1)
////        let item = SeriesDetailItem(entry: entry, absolute: 0, index: 0, source: BookDetailProvider())
////        if let (key, action, object) = item.removeAction {
////            XCTAssertEqual(key, SeriesAction.seriesKey)
////            XCTAssertEqual(action, "button.RemoveSeries")
////            XCTAssertEqual(object as? Series, series)
////        } else {
////            XCTFail()
////        }
////    }
//    
//    func testRemoveActionNil() {
//        let item = SeriesDetailItem(entry: nil, absolute: 0, index: 0, source: BookDetailProvider())
//        XCTAssertNil(item.removeAction)
//    }
//    
//    func testHeading() {
//        let item = SeriesEntryDetailItem(entry: nil, absolute: 0, index: 0, source: BookDetailProvider())
//        XCTAssertEqual(item.heading, "")
//        
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let entry = SeriesEntry(context: context)
//        entry.position = 2
//        let item2 = SeriesEntryDetailItem(entry: entry, absolute: 0, index: 0, source: BookDetailProvider())
//        XCTAssertEqual(item2.heading, "#2")
//    }
}
