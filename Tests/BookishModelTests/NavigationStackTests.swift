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
        
        XCTAssertEqual(stack.goBack(), "one")
        XCTAssertEqual(stack.current, "one")
        
        XCTAssertNil(stack.goBack())
    }
    
    func testGoForward() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()
        stack.push("one")
        stack.push("two")
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertEqual(stack.goBack(), "one")
        XCTAssertEqual(stack.current, "one")
        
        XCTAssertEqual(stack.goForward(), "two")
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertNil(stack.goForward())
    }
    
    func testGoBackThenPush() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()
        stack.push("one")
        stack.push("two")
        XCTAssertEqual(stack.current, "two")
        
        XCTAssertEqual(stack.goBack(), "one")
        XCTAssertEqual(stack.current, "one")
        
        stack.push("three")
        XCTAssertEqual(stack.current, "three")

        XCTAssertEqual(stack.goBack(), "one")
        XCTAssertEqual(stack.current, "one")

        XCTAssertEqual(stack.goForward(), "three")
        XCTAssertEqual(stack.current, "three")

        XCTAssertNil(stack.goForward())
    }
    
    func testReset() {
        navigationStackChannel.enabled = true
        let stack = NavigationStack<String>()
        stack.push("one")
        stack.push("two")
        XCTAssertEqual(stack.current, "two")

        stack.reset(to: "three")
        XCTAssertEqual(stack.current, "three")
        
        stack.reset()
        XCTAssertNil(stack.current)
    }
}
