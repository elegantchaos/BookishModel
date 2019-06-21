// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class RoleDetailProviderTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let role = Role(context: context)
        let provider = role.getProvider()
        XCTAssertTrue(provider is RoleDetailProvider)
    }
    
    func testStandardDetails() {
        let details = RoleDetailProvider.standardDetails(showDebug: false)
        let debugDetails = RoleDetailProvider.standardDetails(showDebug: true)
        XCTAssertTrue(details.count > 0)
        XCTAssertTrue(debugDetails.count > details.count)
    }
    
    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = RoleDetailProvider()
        
        source.filter(for: ModelSelection(), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)
        
        let role = Role.named(Role.StandardName.author, in: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: role)
        
        source.filter(for: ModelSelection([role]), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 2)
        XCTAssertEqual(source.sectionCount, 1)
        
        let book = Book(context: context)
        relationship.addToBooks(book)
        
        source.filter(for: ModelSelection([role]), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 2)
        XCTAssertEqual(source.sectionCount, 1)
    }
}
