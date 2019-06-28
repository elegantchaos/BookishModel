// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import XCTest
import CoreData
@testable import BookishModel

class TagsDetailTests: ModelTestCase {
    func testItem() {
        let container = makeTestContainer()
        let source = BookDetailProvider()
        let tag = Tag(context: container.managedObjectContext)
        let item = TagsDetailItem(tags: [tag], absolute: 0, index: 1, source: source)
        XCTAssertNil(item.object)
        XCTAssertEqual(item.tags.count, 1)
    }
    
    func testHeading() {
        let source = BookDetailProvider()
        let item = TagsDetailItem(tags: [], absolute: 0, index: 1, source: source)
        XCTAssertEqual(item.heading, "detail.tag.label")
    }
}
