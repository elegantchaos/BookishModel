// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class ISBNTests: ModelTestCase {
    let valid10 = "3200328584"
    let valid10withX = "013603599X"
    let valid13 = "9783200328587"
    let invalid13 = "1233200328587"

    func testIsISBN10() {
        XCTAssertTrue(valid10.isISBN10)
        XCTAssertTrue(valid10withX.isISBN10)
        
        XCTAssertFalse(valid13.isISBN10)
        XCTAssertFalse(invalid13.isISBN10)
        
        XCTAssertFalse("blah".isISBN10)
    }
    
    func testIsISBN13() {
        XCTAssertFalse(valid10.isISBN13)
        XCTAssertFalse(valid10withX.isISBN13)
        
        XCTAssertTrue(valid13.isISBN13)
        XCTAssertFalse(invalid13.isISBN13)
        
        XCTAssertFalse("blah".isISBN13)
    }


}
