// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData

@testable import BookishModel

class ModelObjectTests: ModelTestCase {

//    func testUUID() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let book = Book(context: context)
//        XCTAssertEqual(book.uniqueIdentifier, book.uuid! as NSString)
//    }
//
//    func testMissingUUID() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let book = Book(context: context)
//        book.uuid = nil
//        XCTAssertEqual(book.uniqueIdentifier, ModelObject.missingUUID)
//    }
//
//    func testEntityDescriptionBadContext() {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        #if testFatalErrors && (!os(iOS) || targetEnvironment(simulator))
//        let _ = XCTAssertFatalError {
//            let _ = ModelObject.entityDescription(for: Book.self, in: context)
//        }
//        #endif
//    }
//    
//    func testEntityDescriptionNoEntity() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        #if testFatalErrors && (!os(iOS) || targetEnvironment(simulator))
//        let _ = XCTAssertFatalError {
//            let _ = ModelObject.entityDescription(for: String.self, in: context)
//        }
//        #endif
//    }
//    
//    func testEntityDescriptionFromObject() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let book = Book(context: context)
//        let description = book.entityDescription()
//        XCTAssertEqual(description.name, "Book")
//    }
//
//    func testEntityName() {
//        XCTAssertEqual(ModelObject.entityName, "ModelObject")
//    }
//    
//    func testEntityLabel() {
//        XCTAssertEqual(ModelObject.entityLabel, "ModelObject.label")
//    }
//
//    func testEntityTitle() {
//        XCTAssertEqual(ModelObject.entityTitle, "ModelObject.title")
//    }
//
//    func testEntityPlaceholder() {
//        XCTAssertEqual(ModelObject.entityPlaceholder, "ModelObjectPlaceholder")
//    }
//    
//    func testEntityCount() {
//        XCTAssertEqual(ModelObject.entityCount(0), "ModelObject.count.none")
//        XCTAssertEqual(ModelObject.entityCount(1), "ModelObject.count.singular")
//        XCTAssertEqual(ModelObject.entityCount(2), "ModelObject.count.plural")
//        XCTAssertEqual(ModelObject.entityCount(2, selected: 2), "ModelObject.count.all")
//    }
//    
//    func testGetProvider() {
//        XCTAssertEqual(ModelObject.getProvider().sectionCount, 1)
//    }
//    
//    func testMissingUniqueIdentifier() {
//        let container = makeTestContainer()
//        let context = container.managedObjectContext
//        let book = Book(context: context)
//        book.uuid = nil
//        XCTAssertEqual(book.uniqueIdentifier, ModelObject.missingUUID)
//    }
}
