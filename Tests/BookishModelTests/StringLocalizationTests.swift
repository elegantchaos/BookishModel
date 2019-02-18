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
}
