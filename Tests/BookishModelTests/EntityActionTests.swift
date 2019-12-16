// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel
import Actions
import Datastore

class EntityActionTests: ModelActionTestCase {
    
    func testNewEntity() {
        let info = ActionInfo()
        info[.entityTypeKey] = EntityType.book
        let action = NewEntityAction()
        XCTAssertTrue(checkAction(action, withInfo: info) { monitor in
            // check that the change notification fired ok
            monitor.check(count: monitor.storeChanges[0].added.count, expected: 1)

            // check that we have a new entity
            monitor.store.count(entitiesOfTypes: [.book]) { counts in
                print(monitor.storeChanges)
                monitor.check(count: counts[0], expected: 1)
                monitor.allChecksDone()
            }
        })
    }

    func testDeleteEntityValidation() {
        let book = Entity.named("Test", createAs: .book)
        let info = ActionInfo()
        let action = DeleteEntityAction()
        info[.selection] = [book]
        XCTAssertTrue(checkActionValidation(action, withInfo: info) { monitor in
            let manager = monitor.actionManager
            XCTAssertTrue(manager.validate(identifier: action.identifier, info: info).enabled)
            info[.selection] = []
            XCTAssertFalse(manager.validate(identifier: action.identifier, info: info).enabled)
            XCTAssertFalse(manager.validate(identifier: action.identifier, info: ActionInfo()).enabled)
            monitor.allChecksDone()
        })
    }

    func testDeleteEntity() {
        let book = Entity.named("Test", createAs: .book)
        XCTAssertTrue(checkContainer() { monitor in
            monitor.container.store.get(entity: book) { result in
                let info = ActionInfo()
                info[.selection] = [book]
                let action = DeleteEntityAction()
                self.checkAction(action, withInfo: info, monitor: monitor) { monitor in
                    // check that the change notification fired ok
                    monitor.check(count: monitor.storeChanges[0].deleted.count, expected: 1)
                    
                    // check that we have a new entity
                    monitor.store.count(entitiesOfTypes: [.book]) { counts in
                        print(monitor.storeChanges)
                        monitor.check(count: counts[0], expected: 0)
                        monitor.allChecksDone()
                    }
                }
            }
        })
    }

}
