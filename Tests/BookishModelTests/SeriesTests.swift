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
        let e1 = Entry(context: context)
        e1.book = b
        e1.series = s1
        let s2 = Series(context: context)
        let allSeries: [Series] = context.everyEntity()
        XCTAssertEqual(allSeries.count, 2)
        XCTAssertTrue(allSeries.contains(s1))
        XCTAssertTrue(allSeries.contains(s2))
    }

    func testAllEntries() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let e1 = Entry(context: context)
        let e2 = Entry(context: context)
        let allEntries: [Entry] = context.everyEntity()
        XCTAssertEqual(allEntries.count, 2)
        XCTAssertTrue(allEntries.contains(e1))
        XCTAssertTrue(allEntries.contains(e2))
    }
}
