// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class DetailProviderTests: ModelTestCase {
    func testInserted() {
        let provider = DetailProvider()
        XCTAssertEqual(provider.inserted(details: []).count, 0)
    }

    func testRemoved() {
        let provider = DetailProvider()
        XCTAssertEqual(provider.removed(details: []).count, 0)
    }

    func testUpdated() {
        let provider = DetailProvider()
        XCTAssertEqual(provider.updated(details: [], with: []).count, 0)
    }

    func testCombineItems() {
        class TestProvider: DetailProvider {
            override var sectionCount: Int { return 2}
            override func itemCount(for section: Int) -> Int { return 1 }
            override func info(section: Int, row: Int) -> DetailItem {
                return DetailItem(kind: "test \(section) \(row)", absolute: row, index: section, placeholder: false, source: self)
            }
        }
        
        let provider = TestProvider()
        provider.filter(for: ModelSelection(), editing: false, combining: true, context: TestContext())
        
        XCTAssertEqual(provider.combinedCount, 2)
        XCTAssertEqual(provider.combinedInfo(row: 0).kind, "test 0 0")
        XCTAssertEqual(provider.combinedInfo(row: 1).kind, "test 1 0")
    }
    
    func testVisibleColumns() {
        let provider = DetailProvider()
        provider.filter(for: ModelSelection(), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(provider.visibleColumns, DetailProvider.LabelledColumns)
        provider.filter(for: ModelSelection(), editing: true, combining: false, context: TestContext())
        XCTAssertEqual(provider.visibleColumns, DetailProvider.EditingColumns)
    }
}
