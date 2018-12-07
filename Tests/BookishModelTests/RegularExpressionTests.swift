// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class RegularExpressionTests: XCTestCase {
    
    func testExpression() {
        struct Result: RegularExpressionResult {
            var first = ""
            var last = ""
            var number = 0
        }
        
        let pattern = try! NSRegularExpression(pattern: "(\\w+) (.*) (\\w+)", options: [])
        
        if let match: Result = pattern.firstMatch(of: "Sam 123 Deane", capturing: [\Result.first: 1, \Result.last: 3, \Result.number: 2]) {
            XCTAssertEqual(match.first, "Sam")
            XCTAssertEqual(match.last, "Deane")
            XCTAssertEqual(match.number, 123)
        }
    }

    func testExpression2() {
        class Result {
            var first = ""
            var last = ""
            var number = 0
        }
        
        let pattern = try! NSRegularExpression(pattern: "(\\w+) (.*) (\\w+)", options: [])
        var result = Result()
        if pattern.firstMatch(of: "Sam 123 Deane", capturing: [\Result.first: 1, \Result.last: 3, \Result.number: 2], into: &result) {
            XCTAssertEqual(result.first, "Sam")
            XCTAssertEqual(result.last, "Deane")
            XCTAssertEqual(result.number, 123)
        }
    }
}
