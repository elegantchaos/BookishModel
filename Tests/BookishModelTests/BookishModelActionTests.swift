// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

@testable import BookishModel
import XCTest
import CoreData
import Actions

class BookishModelActionTests: ModelTestCase {
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!
    var actionManager: ActionManager!
    var info: ActionContext.Info = [:]
    
    override func setUp() {
        container = makeTestContainer()
        context = container.viewContext
        actionManager = ActionManager()
        info[ActionContext.modelKey] = context
    }
    
    func count(of type: String, in context: NSManagedObjectContext? = nil) -> Int {
        let requestContext = context != nil ? context! : (self.context as NSManagedObjectContext)
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: type)
        if let result = try? requestContext.fetch(request) {
            return result.count
        }
        return NSNotFound
    }
    
    func testNewPerson() {
        actionManager.register(PersonAction.standardActions())
        
        actionManager.perform(identifier: "NewPerson", sender: self, info: info)
        
        XCTAssertEqual(count(of: "Person"), 1)
    }
}
