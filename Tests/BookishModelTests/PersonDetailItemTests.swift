// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class PersonDetailItemTests: ModelTestCase {

    func testHeadingViewID() {
//        let item = RelationshipDetailItem(absolute: 0, index: 1, source: DetailProvider())
//
//        XCTAssertEqual(item.viewID(for: DetailItem.headingColumnID), RelationshipDetailItem.roleColumnID)
    }

    func testCustomViewID() {
//        let item = RelationshipDetailItem(absolute: 0, index: 1, source: DetailProvider())
//        XCTAssertEqual(item.viewID(for: "custom column"), item.kind)
    }
//
//    func testHeading() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let person = Person(context: context)
//        let relationship = person.relationship(as: "test role")
//
//        let item = RelationshipDetailItem(relationship: relationship, absolute: 0, index: 1, source: DetailProvider())
//        XCTAssertEqual(item.heading, "test role")
//    }
    
    func testPlaceholderHeading() {
//        let item = RelationshipDetailItem(absolute: 0, index: 1, source: DetailProvider())
//        XCTAssertEqual(item.heading, "Person")
    }
    
}
