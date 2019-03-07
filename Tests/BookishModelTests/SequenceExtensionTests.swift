// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class SequenceExtensionTests: ModelTestCase {

    func testCountOccurrences() {
        XCTAssertEqual([].count(instancesOf: 1), 0)
        XCTAssertEqual([2, 3, 2].count(instancesOf: 1), 0)
        XCTAssertEqual([1, 2, 3, 2, 1].count(instancesOf: 1), 2)
        XCTAssertEqual("foobar".count(instancesOf: "o"), 2)
        XCTAssertEqual(["foo", "bar"].count(instancesOf: "foo"), 1)
    }
}
