// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class StringLocalizationTests: ModelTestCase {

    func testLocalized() {
        StringLocalization.registerLocalizationBundle(Bundle(for: type(of: self)))
        XCTAssertEqual("test".localized, "localized")
    }
    
    func testMissing() {
        XCTAssertEqual("missing".localized, "missing")
    }
    
    func testParameters() {
        XCTAssertEqual("parameters".localized(with: ["name": "Fred"]), "Name is Fred.")

    }
    
    func testCount() {
        StringLocalization.registerLocalizationBundle(Bundle(for: type(of: self)))
        XCTAssertEqual("count".localized(count: 0), "none")
        XCTAssertEqual("count".localized(count: 1), "one")
        XCTAssertEqual("count".localized(count: 2), "2")
    }

    func testCountSelection() {
        StringLocalization.registerLocalizationBundle(Bundle(for: type(of: self)))
        XCTAssertEqual("selection".localized(count: 2, selected: 0), "0 of 2 selected")
        XCTAssertEqual("selection".localized(count: 2, selected: 1), "1 of 2 selected")
        XCTAssertEqual("selection".localized(count: 2, selected: 2), "All 2 selected")
    }

}
