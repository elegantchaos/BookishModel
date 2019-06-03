// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishCore

class EntityPredicateTests: CoreDataTestCase {
    func check(predicates: [NSPredicate]) -> Bool {
        let formats = predicates.map { $0.predicateFormat }

        // check a few random attributes to see if predicates were created for them
        let containsRightStuff =
            formats.contains("name CONTAINS[cd] \"test\"") &&
            formats.contains("uuid CONTAINS[cd] \"test\"")
        if !containsRightStuff {
            return false
        }
        
        // check that image wasn't included, since it contains binary data
        let containsWrongStuff = formats.contains("image CONTAINS[cd] \"test\"")
        return !containsWrongStuff
    }
    
    func testTextAttributes() {
        let container = makeTestContainer()
        let description = TestEntity.entityDescription(in: container.viewContext)
        let predicates = description.textAttributePredicates(comparing: "test", using: "contains[cd]")
        XCTAssertTrue(check(predicates: predicates))
    }
    
    func testAnyPredicate() {
        let container = makeTestContainer()
        let description = TestEntity.entityDescription(in: container.viewContext)
        let predicate = description.anyAttributesPredicate(comparing: "test", using: "contains[cd]")
        XCTAssertTrue(predicate is NSCompoundPredicate)
        if let compound = predicate as? NSCompoundPredicate, let subpredicates = compound.subpredicates as? [NSPredicate] {
            XCTAssertTrue(check(predicates: subpredicates))
        }
    }

    func testAllPredicate() {
        let container = makeTestContainer()
        let description = TestEntity.entityDescription(in: container.viewContext)
        let predicate = description.allAttributesPredicate(comparing: "test", using: "contains[cd]")
        XCTAssertTrue(predicate is NSCompoundPredicate)
        if let compound = predicate as? NSCompoundPredicate, let subpredicates = compound.subpredicates as? [NSPredicate] {
            XCTAssertTrue(check(predicates: subpredicates))
        }
    }

}
