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
        
        let mapping = [\Result.first: 1, \Result.last: 3, \Result.number: 2]
        if let match: Result = pattern.firstMatch2(of: "Sam 123 Deane", mappings: mapping) {
            XCTAssertEqual(match.first, "Sam")
            XCTAssertEqual(match.last, "Deane")
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
        let mapping = [\Result.first: 1, \Result.last: 3, \Result.number: 2]
        if pattern.firstMatch2(of: "Sam 123 Deane", mappings: mapping, capture: &result) {
            XCTAssertEqual(result.first, "Sam")
            XCTAssertEqual(result.last, "Deane")
            XCTAssertEqual(result.number, 123)
        }
    }
}
