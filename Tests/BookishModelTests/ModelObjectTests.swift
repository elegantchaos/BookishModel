// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData

@testable import BookishModel

class ModelObjectTests: ModelTestCase {

    func testUUID() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        XCTAssertEqual(book.uniqueIdentifier, book.uuid! as NSString)
    }

    func testMissingUUID() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        book.uuid = nil
        XCTAssertEqual(book.uniqueIdentifier, ModelObject.missingUUID)
    }

    func testEntityDescriptionBadContext() {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let _ = XCTAssertFatalError {
            let _ = ModelObject.entityDescription(for: Book.self, in: context)
        }
    }
    
    func testEntityDescriptionNoEntity() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let _ = XCTAssertFatalError {
            let _ = ModelObject.entityDescription(for: String.self, in: context)
        }
    }
    
    func testEntityDescriptionFromObject() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let book = Book(context: context)
        let description = book.entityDescription()
        XCTAssertEqual(description.name, "Book")
    }

    func testCategoryLabel() {
        XCTAssertEqual(ModelObject.entityLabel, "label.ModelObject")
    }

    func testCategoryTitle() {
        XCTAssertEqual(ModelObject.entityTitle, "title.ModelObject")
    }

    func testCategoryPlaceholderName() {
        XCTAssertEqual(ModelObject.entityPlaceholder, "ModelObjectPlaceholder")
    }
}
