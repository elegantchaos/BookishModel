// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class DecodingErrorTests: ModelTestCase {

    struct Test: Decodable {
        let foo: String
    }

    func decode(json: String, expecting: String) -> Bool {
        let whitespace = CharacterSet.whitespacesAndNewlines
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(Test.self, from: data)
            XCTFail("shouldn't decode")
        } catch DecodingError.dataCorrupted(let context) {
            let actual = context.detailedDescription(for: data).trimmingCharacters(in: whitespace)
            let expected = expecting.trimmingCharacters(in: whitespace)
            XCTAssertEqual(actual, expected)
            return actual == expected
        } catch DecodingError.typeMismatch(let type, let context) {
            let actual = context.detailedDescription(for: data).trimmingCharacters(in: whitespace)
            let expected = expecting.trimmingCharacters(in: whitespace)
            XCTAssertEqual(actual, expected)
            return actual == expected
        } catch {
            XCTFail("unexpected error \(error)")
        }
        
        return false
    }
    
    func testFromPlist() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "JSON Errors", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        let items = plist as! [[String:String]]
        
        for item in items {
            let json = item["json"]!
            let expected = item["expected"]!
            XCTAssertTrue(decode(json: json, expecting: expected))
        }
    }
}
