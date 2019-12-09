// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class RoleActionTests: ModelActionTestCase, RoleViewer, RoleLifecycleObserver {
    func created(role: Role) {
        roleObserved = role
    }
    
    func deleted(role: Role) {
        roleObserved = role
    }
    
    var roleObserved: Role?
    
    func reveal(role: Role) {
        roleObserved = role
    }
    
    func testNewRole() {
//        info.addObserver(self)
//        XCTAssertTrue(actionManager.validate(identifier: "NewRole", info: info).enabled)
//        actionManager.perform(identifier: "NewRole", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Role"), 1)
//        XCTAssertNotNil(roleObserved)
    }
    
    func testDeleteRoles() {
//        let role = Role(context: context)
//        XCTAssertEqual(count(of: "Role"), 1)
//
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteRole", info: info).enabled)
//        info.addObserver(self)
//        info[ActionContext.selectionKey] = [role]
//
//        XCTAssertTrue(actionManager.validate(identifier: "DeleteRole", info: info).enabled)
//        actionManager.perform(identifier: "DeleteRole", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Role"), 0)
//        XCTAssertEqual(roleObserved, role)
//
//        info[ActionContext.selectionKey] = []
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteRole", info: info).enabled)
//
//        info[ActionContext.selectionKey] = [Book(context: context)]
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteRole", info: info).enabled)
//
//        info[ActionContext.selectionKey] = [Book(context: context)]
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteRole", info: ActionInfo()).enabled)
        
    }
    
    func testRevealRole() {
//        let role = Role(context: context)
//        XCTAssertFalse(actionManager.validate(identifier: "RevealRole", info: info).enabled)
//        info[ActionContext.rootKey] = self
//        info[RoleAction.roleKey] = role
//        XCTAssertTrue(actionManager.validate(identifier: "RevealRole", info: info).enabled)
//        actionManager.perform(identifier: "RevealRole", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(roleObserved, role)
    }
    
}
