
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishCore

class NSManagedObjectTests: XCTestCase {
    
    @objc(TestEntity) public class TestEntity: NSManagedObject {
        @objc dynamic var name: String?
    }
    
    func makeTestModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "TestEntity"
        entity.managedObjectClassName = "TestEntity"

        let attribute = NSAttributeDescription()
        attribute.name = "name"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        
        entity.properties = [
            attribute
        ]
        
        model.entities = [
            entity
        ]
        
        return model
    }
    
    func makeTestContainer() -> NSPersistentContainer {
        let model = makeTestModel()
        let container = NSPersistentContainer(name: "test", managedObjectModel: model)
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("failed to load \(error)")
            }
            
            print("loaded \(description)")
        }
        
        return container
    }

    func testEntityCount() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        XCTAssertEqual(TestEntity.countEntities(in: context), 0)
        let object = TestEntity(in: container.viewContext)
        object.name = "test1"
        XCTAssertEqual(TestEntity.countEntities(in: context), 1)
        
        let object2 = TestEntity(in: container.viewContext)
        object2.name = "test2"
        XCTAssertEqual(TestEntity.countEntities(in: context), 2)
    }

    func testNamed() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        XCTAssertEqual(TestEntity.countEntities(in: context), 0)
        let object = TestEntity.named("test", in: container.viewContext, createIfMissing: true)
        XCTAssertEqual(object?.name, "test")
    }

}
