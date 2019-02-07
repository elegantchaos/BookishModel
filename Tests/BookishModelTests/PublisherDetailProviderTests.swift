// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PublisherDetailProviderTests: ModelTestCase {
    func testProvider() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let publisher = Publisher(context: context)
        let provider = publisher.getProvider()
        XCTAssertTrue(provider is PublisherDetailProvider)
    }
    
    func testRowCount() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let source = PublisherDetailProvider()
        
        source.filter(for: [], editing: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)

        let publisher = Publisher(context: context)
        publisher.name = "Test"
        publisher.notes = "Some notes"
        
        source.filter(for: [publisher], editing: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 0)
        XCTAssertEqual(source.sectionCount, 1)

        let book = Book(context: context)
        publisher.addToBooks(book)
        
        source.filter(for: [publisher], editing: false, context: TestContext())
        XCTAssertEqual(source.itemCount(for: 0), 1)
        XCTAssertEqual(source.sectionCount, 1)
    }
   }
