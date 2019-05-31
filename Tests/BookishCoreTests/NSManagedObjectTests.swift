
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishCore

class NSManagedObjectTests: XCTestCase {
    
    @objc(TestEntity) public class TestEntity: NSManagedObject {
        @objc dynamic var name: String?
        @objc dynamic var uuid: String?
    }
    
    func makeTestModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "TestEntity"
        entity.managedObjectClassName = "TestEntity"

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = true

        let uuidAttribute = NSAttributeDescription()
        uuidAttribute.name = "uuid"
        uuidAttribute.attributeType = .stringAttributeType
        uuidAttribute.isOptional = true

        entity.properties = [
            nameAttribute, uuidAttribute
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
        let object = TestEntity(in: context)
        object.name = "test1"
        XCTAssertEqual(TestEntity.countEntities(in: context), 1)
        
        let object2 = TestEntity(in: context)
        object2.name = "test2"
        XCTAssertEqual(TestEntity.countEntities(in: context), 2)
    }

    func testNamed() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        XCTAssertEqual(TestEntity.countEntities(in: context), 0)
        XCTAssertNil(TestEntity.named("test", in: context, createIfMissing: false))
        let object = TestEntity.named("test", in: context)
        XCTAssertEqual(object.name, "test")
        let optional = TestEntity.named("test2", in: context, createIfMissing: true)
        XCTAssertEqual(optional?.name, "test2")
        let another = TestEntity.named("test", in: context)
        XCTAssertTrue(object === another)
    }

    func testWithIdentifier() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        XCTAssertEqual(TestEntity.countEntities(in: context), 0)
        XCTAssertNil(TestEntity.withIdentifier("test", in: context))
        let object = TestEntity.named("foo", in: context)
        object.uuid = "test"
        
        let found = TestEntity.withIdentifier("test", in: context)
        XCTAssertEqual(found?.uuid, "test")
    }
    
    func testEveryEntity() {
        let container = makeTestContainer()
        let context = container.viewContext
        let object1 = TestEntity.named("test1", in: context)
        let object2 = TestEntity.named("test2", in: context)
        
        let every = TestEntity.everyEntity(in: context)
        XCTAssertTrue(every.contains(object1))
        XCTAssertTrue(every.contains(object2))
        XCTAssertEqual(every.count, 2)
    }
    
    func testEntityDescriptionForClass() {
        let container = makeTestContainer()
        let context = container.viewContext
        let description = TestEntity.entityDescription(in: context)
        XCTAssertEqual(description.name, "TestEntity")
    }

    func testEntityDescriptionForInstance() {
        let container = makeTestContainer()
        let context = container.viewContext
        let object = TestEntity.named("test", in: context)
        let description = object.entityDescription()
        XCTAssertEqual(description.name, "TestEntity")
    }
}
