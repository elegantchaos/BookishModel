// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class SequenceExtensionTests: ModelTestCase {

    func testCountOccurrences() {
        XCTAssertEqual([].countOccurencesOf(1), 0)
        XCTAssertEqual([2, 3, 2].countOccurencesOf(1), 0)
        XCTAssertEqual([1, 2, 3, 2, 1].countOccurencesOf(1), 2)
        XCTAssertEqual("foobar".countOccurencesOf("o"), 2)
        XCTAssertEqual(["foo", "bar"].countOccurencesOf("foo"), 1)
    }
}
