// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class RelationshipTests: ModelTestCase {

    func testRelationshipIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.role?.uuid = "author"
        person.uuid = "person"
        XCTAssertEqual(relationship.uniqueIdentifier, "person-author" as NSString)
    }
    
    func testRelationshipMissingIdentifier() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        let relationship = person.relationship(as: "author")
        relationship.role?.uuid = nil
        person.uuid = nil
        XCTAssertEqual(relationship.uniqueIdentifier, ModelObject.missingUUID)
    }

}
