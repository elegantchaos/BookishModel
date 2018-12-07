// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class SeriesActionTests: ModelActionTestCase, SeriesViewer {
    var seriesRevealed: Series?

    func reveal(series: Series) {
        seriesRevealed = series
    }
    
    func testNewSeries() {
        actionManager.perform(identifier: "NewSeries", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Series"), 1)
    }
    
    func testDeleteSeriess() {
        let series = Series(context: context)
        XCTAssertEqual(count(of: "Series"), 1)
        
        info[ActionContext.selectionKey] = [series]
        
        actionManager.perform(identifier: "DeleteSeries", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Series"), 0)
    }
    
    func testRevealSeries() {
        let series = Series(context: context)
        info[ActionContext.rootKey] = self
        info[SeriesAction.seriesKey] = series
        actionManager.perform(identifier: "RevealSeries", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(seriesRevealed, series)
    }
    
}
