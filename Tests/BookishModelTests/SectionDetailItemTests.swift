// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class SectionDetailItemTests: ModelTestCase {

    func testHeading() {
        let item = SectionDetailItem(kind: "test", absolute: 0, index: 0, placeholder: false, source: DetailProvider())
        XCTAssertEqual(item.heading, "")
    }

    func testViewID() {
        let item = SectionDetailItem(kind: "test", absolute: 0, index: 0, placeholder: false, source: DetailProvider())
        XCTAssertEqual(item.viewID(for: DetailItem.detailColumnID), "section")
        XCTAssertEqual(item.viewID(for: DetailItem.controlColumnID), DetailItem.controlColumnID)
    }
}
