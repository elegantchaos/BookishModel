// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Datastore
import XCTest
import XCTestExtensions

@testable import BookishModel
@testable import Actions

class ModelActionTestCase: ModelTestCase {
    public class ActionMonitor: WrappedTestMonitor<ContainerMonitor> {
        let actionManager: ActionManager
        let storeChanges: [EntityChanges]
        
        init(actionManager: ActionManager, storeChanges: [EntityChanges], wrappedMonitor: ContainerMonitor) {
            self.actionManager = actionManager
            self.storeChanges = storeChanges
            super.init(wrappedMonitor: wrappedMonitor)
        }
        
        var store: Datastore {
            return wrappedMonitor.container.store
        }
    }
    
    func checkAction(_ action: Action, withInfo info: ActionInfo, checker: @escaping (ActionMonitor) -> Void) -> Bool {
        let result = checkContainer() { monitor in
            self.checkAction(action, withInfo: info, monitor: monitor, checker:checker)
        }
        
        return result
    }

    func checkActionValidation(_ action: Action, withInfo info: ActionInfo, checker: @escaping (ActionMonitor) -> Void) -> Bool {
        let result = checkContainer() { monitor in
            let manager = ActionManager()
            info[.model] = monitor.container
            manager.register([action])
            let actionMonitor = ActionMonitor(actionManager: manager, storeChanges: [], wrappedMonitor: monitor)
            checker(actionMonitor)
        }
        
        return result
    }

    func checkAction(_ action: Action, withInfo info: ActionInfo, monitor: ContainerMonitor, checker: @escaping (ActionMonitor) -> Void) {
        let actionManager = ActionManager()
        actionManager.register([action])
        var storeChanges: [EntityChanges] = []
        var token: NSObjectProtocol
        token = NotificationCenter.default.addObserver(forName: .EntityChangedNotification, object: nil, queue: nil) { notification in
            if let changes = notification.entityChanges {
                storeChanges.append(changes)
            }
        }
        info[.model] = monitor.container
        info.registerNotification(notification: { (stage, context) in
            switch stage {
                case .didPerform, .didFail:
                    let actionMonitor = ActionMonitor(actionManager: actionManager, storeChanges: storeChanges, wrappedMonitor: monitor)
                    checker(actionMonitor)
                    NotificationCenter.default.removeObserver(token)
                case .willPerform:
                    break
            }
        })
        
        actionManager.perform(identifier: action.identifier, info: info)
    }

//    func count(of type: String, in context: NSManagedObjectContext? = nil) -> Int {
//        let requestContext = context != nil ? context! : (self.context as NSManagedObjectContext)
//        var count = NSNotFound
//        requestContext.performAndWait {
//            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: type)
//            if let result = try? requestContext.fetch(request) {
//                count = result.count
//            }
//        }
//        return count
//    }
    
//    func testCoverage() {
//        // not real tests - just here to fill in coverage for some untestable areas
//        info[ActionContext.model] = nil
//        actionManager.perform(identifier: "ModelAction", info: info)
//        actionManager.perform(identifier: "ModelAction", info: info)
//    }
    
}

class ModelActionTests: ModelActionTestCase {
    func testModelActionValidate() {
        let info = ActionInfo()
        let action = ModelAction()
        XCTAssertTrue(checkAction(action, withInfo: info) { monitor in
            let actionManager = monitor.actionManager
            XCTAssertTrue(actionManager.validate(identifier: action.identifier, info: info).enabled)
            XCTAssertFalse(actionManager.validate(identifier: action.identifier, info: ActionInfo()).enabled)
            monitor.allChecksDone()
        })

    }
}
