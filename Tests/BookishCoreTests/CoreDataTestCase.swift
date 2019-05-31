// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishCore

class CoreDataTestCase: XCTestCase {
    
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
}

