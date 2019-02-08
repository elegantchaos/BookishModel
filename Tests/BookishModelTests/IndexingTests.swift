// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class IndexingTests: XCTestCase {

    func testSectionName() {
        XCTAssertNil(Indexing.sectionName(for: nil))
        XCTAssertNil(Indexing.sectionName(for: ""))
        XCTAssertEqual(Indexing.sectionName(for: "test"), "t")
        XCTAssertEqual(Indexing.sectionName(for: "123"), "#")
        XCTAssertEqual(Indexing.sectionName(for: "{"), "•")
    }

    func testTitleSort() {
        XCTAssertEqual(Indexing.titleSort(for: "Blah"), "Blah")
        XCTAssertEqual(Indexing.titleSort(for: "The Blah"), "Blah")
    }
    
    func testNameSort() {
        XCTAssertNil(Indexing.nameSort(for: nil))
        XCTAssertEqual(Indexing.nameSort(for: ""), "")
        XCTAssertEqual(Indexing.nameSort(for: " "), " ")
        XCTAssertEqual(Indexing.nameSort(for: "Blah"), "Blah")
        XCTAssertEqual(Indexing.nameSort(for: "A Blah"), "Blah, A")
        XCTAssertEqual(Indexing.nameSort(for: "A N Blah"), "Blah, A N")
    }
}
