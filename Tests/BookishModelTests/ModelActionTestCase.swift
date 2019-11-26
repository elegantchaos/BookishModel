// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class ModelActionTestCase: ModelTestCase {
    var context: NSManagedObjectContext!
    var container: CollectionContainer!
    var actionManager: ActionManager!
    var info: ActionInfo = ActionInfo()
    var expectation: XCTestExpectation!
    
    override func setUp() {
        container = makeTestContainer()
        context = container.managedObjectContext
        actionManager = ActionManager()
        actionManager.register(ModelAction.standardActions())
        actionManager.register([ModelAction(identifier: "ModelAction")]) // base class, registered for testing only
        actionManager.register([ModelAction(identifier: "ModelAction")]) // base class, registered for testing only

        info[ActionContext.modelKey] = context
        info.registerNotification { (stage, context) in
            if stage == .didPerform {
                self.expectation.fulfill()
            }
        }
        expectation = XCTestExpectation(description: "action done")
    }
    
    func count(of type: String, in context: NSManagedObjectContext? = nil) -> Int {
        let requestContext = context != nil ? context! : (self.context as NSManagedObjectContext)
        var count = NSNotFound
        requestContext.performAndWait {
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: type)
            if let result = try? requestContext.fetch(request) {
                count = result.count
            }
        }
        return count
    }
    
    func testCoverage() {
        // not real tests - just here to fill in coverage for some untestable areas
        info[ActionContext.modelKey] = nil
        actionManager.perform(identifier: "ModelAction", info: info)
        actionManager.perform(identifier: "ModelAction", info: info)
    }
    
    func testModelActionValidate() {
        XCTAssertTrue(actionManager.validate(identifier: "ModelAction", info: info).enabled)
        XCTAssertFalse(actionManager.validate(identifier: "ModelAction", info: ActionInfo()).enabled)
    }
}
