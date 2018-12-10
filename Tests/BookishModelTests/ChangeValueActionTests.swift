// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class ChangeValueActionTests: ModelActionTestCase {
    func testChangeValue() {
        let book = Book(context: context)
        XCTAssertNil(book.asin)
        XCTAssertFalse(actionManager.validate(identifier: "ChangeValue", info: info).enabled)
        info[ActionContext.selectionKey] = [book]
        info[ChangeValueAction.valueKey] = "blah"
        info[ChangeValueAction.propertyKey] = "asin"
        
        XCTAssertTrue(actionManager.validate(identifier: "ChangeValue", info: info).enabled)
        actionManager.perform(identifier: "ChangeValue", info: info)
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(book.asin, "blah")
    }

}
