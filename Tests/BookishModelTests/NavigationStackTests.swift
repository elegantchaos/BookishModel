// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class NavigationStackTests: ModelTestCase {
    
    func testPush() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()

        stack.push("one")
        XCTAssertEqual(stack.current, "one")
        
        stack.push("two")
        XCTAssertEqual(stack.current, "two")
    }

    func testGoBack() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()
        stack.push("one")
        stack.push("two")
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertTrue(stack.goBack())
        XCTAssertEqual(stack.current, "one")
        
        XCTAssertFalse(stack.goBack())
    }
    
    func testGoForward() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()
        stack.push("one")
        stack.push("two")
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertTrue(stack.goBack())
        XCTAssertEqual(stack.current, "one")
        
        XCTAssertTrue(stack.goForward())
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertFalse(stack.goForward())
    }
}
