// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class DecodingErrorTests: ModelTestCase {

    func testDecodingError() {
        struct Test: Decodable {
            let foo: String
        }
        
        let json = """
                    {
                    "foo": bar
                    }
                """
        
        let expected = """
                        The given data was not valid JSON.
                        Invalid value around character 17.


                        0:     {
                        1:→    "foo": bar ←
                        1:            ↑
                        2:     }
                        
                        """
        
        let data = json.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(Test.self, from: data)
            XCTFail("shouldn't decode")
        } catch DecodingError.dataCorrupted(let context) {
            XCTAssertEqual(context.detailedDescription(for: data), expected)
        } catch {
            XCTFail("unexpected error")
        }
    }
}
