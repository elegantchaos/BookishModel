// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PublisherDetailTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let publisher = Publisher(context: context)
        let provider = publisher.getProvider()
        XCTAssertTrue(provider is PublisherDetailProvider)
    }

    func testStandardDetails() {
        let details = PublisherDetailProvider.standardDetails(showDebug: false)
        let debugDetails = PublisherDetailProvider.standardDetails(showDebug: true)
        XCTAssertTrue(details.count > 0)
        XCTAssertTrue(debugDetails.count > details.count)
    }

    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = PublisherDetailProvider()
        
        source.filter(for: ModelSelection(), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.itemCount(for: 1), 0)
        XCTAssertEqual(source.sectionCount, 2)

        let publisher = Publisher(context: context)
        publisher.name = "Test"
        publisher.notes = "Some notes"
        
        source.filter(for: ModelSelection([publisher]), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 3)
        XCTAssertEqual(source.itemCount(for: 1), 0)
        XCTAssertEqual(source.sectionCount, 2)

        source.filter(for: ModelSelection([publisher]), editing: false, combining: false, context: TestContext(showDebug: true))
        XCTAssertEqual(source.itemCount(for: 0), 4)
        XCTAssertEqual(source.itemCount(for: 1), 0)
        XCTAssertEqual(source.sectionCount, 2)

        let book = Book(context: context)
        publisher.add(book)
        
        source.filter(for: ModelSelection([publisher]), editing: false, combining: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 3)
        XCTAssertEqual(source.itemCount(for: 1), 1)
        XCTAssertEqual(source.sectionCount, 2)
    }
    
    func testRemoveAction() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let publisher = Publisher(context: context)
        let item = PublisherDetailItem(publisher: publisher, absolute: 0, index: 0, source: BookDetailProvider())
        if let (key, action, object) = item.removeAction {
            XCTAssertEqual(key, PublisherAction.publisherKey)
            XCTAssertEqual(action, "button.RemovePublisher")
            XCTAssertEqual(object as? Publisher, publisher)
        } else {
            XCTFail()
        }
    }
    
    func testRemoveActionNil() {
        let item = PublisherDetailItem(publisher: nil, absolute: 0, index: 0, source: BookDetailProvider())
        XCTAssertNil(item.removeAction)
    }

    
   }
