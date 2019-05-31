
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishCore

class NSManagedObjectContextTests: CoreDataTestCase {
    func testFetcher() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        let fetcher: NSFetchRequest<TestEntity> = context.fetcher()
        XCTAssertEqual(fetcher.entity?.name, "TestEntity")
    }

    func testEntityDescription() {
        let container = makeTestContainer()
        let context = container.viewContext
        
        let description = context.entityDescription(for: TestEntity.self)
        XCTAssertEqual(description.name, "TestEntity")
    }
    
    func testURI() {
        let container = makeTestContainer()
        let context = container.viewContext
        let object = TestEntity.named("test", in: context)
        let url = object.objectID.uriRepresentation()
        let found = context.object(uri: url.absoluteString) as? TestEntity
        XCTAssertEqual(found?.name, "test")
    }
    
    func testInvalidURI() {
        let container = makeTestContainer()
        let context = container.viewContext
        let found = context.object(uri: "x-coredata:///TestEntity/tC6D3EA7C-A29D-4AA8-AB4B-ACB3D96793912") as? TestEntity
        XCTAssertNil(found)
    }

}
