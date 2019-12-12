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
        
        init(actionManager: ActionManager, wrappedMonitor: ContainerMonitor) {
            self.actionManager = actionManager
            super.init(wrappedMonitor: wrappedMonitor)
        }
        
        var store: Datastore {
            return wrappedMonitor.container.store
        }
    }
    
    func checkAction(_ action: Action, withInfo info: ActionInfo, checker: @escaping (ActionMonitor) -> Void) -> Bool {
        let actionManager = ActionManager()
        actionManager.register([action])
        let result = checkContainer() { monitor in
            info[.model] = monitor.container
            info.registerNotification(notification: { (stage, context) in
                if stage == .didPerform {
                    let actionMonitor = ActionMonitor(actionManager: actionManager, wrappedMonitor: monitor)
                    checker(actionMonitor)
                }
            })
            
            actionManager.perform(identifier: action.identifier, info: info)
        }
        
        return result
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
