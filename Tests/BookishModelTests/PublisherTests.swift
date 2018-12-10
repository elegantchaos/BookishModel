// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PublisherTests: ModelTestCase {
    
    func testAllPublishers() {
        let container = makeTestContainer()
        let context = container.viewContext
        let p1 = Publisher(context: context)
        let p2 = Publisher(context: context)
        let allPublishers: [Publisher] = context.everyEntity()
        XCTAssertEqual(allPublishers.count, 2)
        XCTAssertTrue(allPublishers.contains(p1))
        XCTAssertTrue(allPublishers.contains(p2))
    }
}
