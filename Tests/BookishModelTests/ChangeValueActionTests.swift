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

    func testSend() {
        
        // for the purposes of the test, the sender needs to be something capable of injecting the model
        // (this would typically come from the context)
        struct Sender: ActionResponder, ActionContextProvider {
            let context: NSManagedObjectContext
            func next() -> ActionResponder? { return nil }
            func provide(context actionContext: ActionContext) { actionContext[ActionContext.modelKey] = self.context }
        }
        
        let book = Book(context: context)
        let changed = expectation(description: "changed")
        let observer = book.observe(\Book.asin) { (book, change) in
            changed.fulfill()
        }
        var observers = [observer]
        ChangeValueAction.send("ChangeValue", from: Sender(context: context), manager: actionManager, property: "asin", value: "blah", to: book)
        
        wait(for: [changed], timeout: 1.0)
        observers.removeAll()
        XCTAssertEqual(book.asin, "blah")
    }

}
