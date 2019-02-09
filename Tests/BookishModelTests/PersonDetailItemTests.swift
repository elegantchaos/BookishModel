// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class PersonDetailItemTests: ModelTestCase {

    func testHeadingViewID() {
        let item = PersonDetailItem(absolute: 0, index: 1, source: DetailProvider(template: []))
        
        XCTAssertEqual(item.viewID(for: DetailItem.headingColumnID), PersonDetailItem.roleColumnID)
    }

    func testCustomViewID() {
        let item = PersonDetailItem(absolute: 0, index: 1, source: DetailProvider(template: []))
        XCTAssertEqual(item.viewID(for: "custom column"), item.kind)
    }

    func testHeading() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let relationship = person.relationship(as: "test role")

        let item = PersonDetailItem(relationship: relationship, absolute: 0, index: 1, source: DetailProvider(template: []))
        XCTAssertEqual(item.heading, "test role")
    }
    
    func testPlaceholderHeading() {
        let item = PersonDetailItem(absolute: 0, index: 1, source: DetailProvider(template: []))
        XCTAssertEqual(item.heading, "Person")
    }
    
}
