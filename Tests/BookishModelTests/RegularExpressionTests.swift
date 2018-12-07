// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class RegularExpressionTests: XCTestCase {
    
    class Result: ResultStructure {
        static func make() -> ResultStructure {
            return Result()
        }
        
        var first = ""
        var last = ""
    }
    
    func testExpression() {
        let pattern = try! NSRegularExpression(pattern: "(\\w+) (\\w+)", options: [])
        
        let mapping = [\Result.first: 1, \Result.last: 2]
        if let match: Result = pattern.firstMatchX(of: "Sam Deane", mappings: mapping) {
            print(match.first)
            print(match.last)
        }
    }
    
}
