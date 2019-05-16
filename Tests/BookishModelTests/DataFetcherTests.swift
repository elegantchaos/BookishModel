// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class DataFetcherTests: XCTestCase {
    func testStub() {
        let fetcher = DataFetcher()
        XCTAssertNil(fetcher.info(for: URL(fileURLWithPath: "")))
    }
    
    func testTestFetcher() {
        let fetcher = TestDataFetcher(data: ["test": "blah"])
        let info = fetcher.info(for: URL(fileURLWithPath: ""))
        XCTAssertEqual(info?["test"] as? String, "blah")
    }
    
    func testJSON() {
        let url = temporaryFile()
        let json = #"{ "test" : "blah" }"#
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        XCTAssertNoThrow(try json.write(to: url, atomically: true, encoding: .utf8))
        let fetcher = JSONDataFetcher()
        let info = fetcher.info(for: url)
        XCTAssertEqual(info?["test"] as? String, "blah")
    }
    
    func testJSONFailure() {
        let url = temporaryFile()
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let fetcher = JSONDataFetcher()
        XCTAssertNil(fetcher.info(for: url))
    }
}
