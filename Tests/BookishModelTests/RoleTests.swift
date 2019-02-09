// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class RoleTests: ModelTestCase {

    func testUniqueRoles() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let role1 = Role.named("author", in: context)
        XCTAssertEqual(role1.name, "author")
        let role2 = Role.named("author", in: context)
        XCTAssertTrue(role1 === role2)
    }
    
    func testAllRoles() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let role1 = Role.named("author1", in: context)
        let role2 = Role.named("author2", in: context)
        let roles = Role.allRoles(context: context)
        XCTAssertTrue(roles[0] === role1)
        XCTAssertTrue(roles[1] === role2)
    }
    
    func testAllRolesEmpty() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let roles = Role.allRoles(context: context)
        XCTAssertEqual(roles.count, 0)
    }
    
    func testDefaultRoleNames() {
        let names = Role.StandardName.allNames
        XCTAssertTrue(names.count > 0)
    }

}
