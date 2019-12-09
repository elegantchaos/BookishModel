// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class SeriesActionTests: ModelActionTestCase, SeriesViewer, SeriesLifecycleObserver {
    func created(series: Series) {
        seriesObserved = series
    }
    
    func deleted(series: Series) {
        seriesObserved = series
    }
    
    var seriesObserved: Series?

    func reveal(series: Series) {
        seriesObserved = series
    }
    
    func testNewSeries() {
//        info.addObserver(self)
//        XCTAssertTrue(actionManager.validate(identifier: "NewSeries", info: info).enabled)
//        actionManager.perform(identifier: "NewSeries", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Series"), 1)
//        XCTAssertNotNil(seriesObserved)
    }
    
    func testDeleteSeriess() {
//        let series = Series(context: context)
//        XCTAssertEqual(count(of: "Series"), 1)
//
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteSeries", info: info).enabled)
//        info.addObserver(self)
//        info[ActionContext.selectionKey] = [series]
//
//        XCTAssertTrue(actionManager.validate(identifier: "DeleteSeries", info: info).enabled)
//        actionManager.perform(identifier: "DeleteSeries", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Series"), 0)
//        XCTAssertEqual(seriesObserved, series)
//
//        info[ActionContext.selectionKey] = []
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteSeries", info: info).enabled)
//
//        info[ActionContext.selectionKey] = [Book(context: context)]
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteSeries", info: info).enabled)
//
//        info[ActionContext.selectionKey] = [Book(context: context)]
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteSeries", info: ActionInfo()).enabled)

    }
    
    func testRevealSeries() {
//        let series = Series(context: context)
//        XCTAssertFalse(actionManager.validate(identifier: "RevealSeries", info: info).enabled)
//        info[ActionContext.rootKey] = self
//        info[SeriesAction.seriesKey] = series
//        XCTAssertTrue(actionManager.validate(identifier: "RevealSeries", info: info).enabled)
//        actionManager.perform(identifier: "RevealSeries", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(seriesObserved, series)
    }
    
}
