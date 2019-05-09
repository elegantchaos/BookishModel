// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class MarkupUtilityTests: XCTestCase {
    
    struct TestState: TagProcessorState {
        var text: String = ""
        var foo: String = ""
        var data: String = ""
    }
    
    class TestHandler: TagHandler<TestState> {
        required init(name: String = "", attributes: [String : String] = [:], processor: TagProcessor<TestState>) {
            super.init(name: name, attributes: attributes, processor: processor)
            if let string = attributes["foo"] {
                processor.state.foo = string
            }
        }
        
        override func processor(_ processor: TagProcessor<MarkupUtilityTests.TestState>, foundText text: String) {
            processor.state.text = text
        }
        
        override func processor(_ processor: TagProcessor<MarkupUtilityTests.TestState>, foundData data: Data) {
            if let string = String(data: data, encoding: .utf8) {
                processor.state.data = string
            }
        }
    }
    
    class TestProcessor: TagProcessor<TestState> {
        override init() {
            super.init()
            register(handler: TestHandler.self, for: ["test"])
            register(handler: TagHandler.self, for: ["tag"])
        }
        
        override var parser: TagParser? {
            return XMLTagParser(processor: self)
        }
    }

    func testExample() {
        let processor = TestProcessor()
        processor.parse(text: "<test foo=\"bar\">text</test><tag>blah</tag><![CDATA[hello world]]>")
        XCTAssertEqual(processor.state.text, "text")
        XCTAssertEqual(processor.state.foo, "bar")
    }


}
