// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class ISBNTests: ModelTestCase {

    func testIsISBN10() {
        XCTAssertTrue("3200328584".isISBN10)
        XCTAssertFalse("9783200328587".isISBN10)
        XCTAssertFalse("1233200328587".isISBN10)
        XCTAssertFalse("blah".isISBN10)
    }
    
    func testIsISBN13() {
        XCTAssertFalse("3200328584".isISBN13)
        XCTAssertTrue("9783200328587".isISBN13)
        XCTAssertFalse("1233200328587".isISBN13)
        XCTAssertFalse("blah".isISBN13)
    }


}
