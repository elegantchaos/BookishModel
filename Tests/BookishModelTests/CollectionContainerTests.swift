// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class CollectionContainerTests: ModelTestCase {

    func makeTestContainer(name: String, url: URL? = nil, mode: CollectionContainer.PopulateMode = .defaultRoles) -> CollectionContainer {
        let expectation = self.expectation(description: "made")
        let container = CollectionContainer(name: name, url: url, mode: mode) { (container, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(container)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return container
    }
    
    func testCreateEmpty() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .empty)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Role.self), 0)
    }
    
    func testCreateDefaultRoles() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .defaultRoles)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Role.self), Role.StandardName.allCases.count)
    }

    func testCreateTestData() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .testData)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 4)
    }

    func testCreateSampleData() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .sampleData)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 1356) // sample data file is created with bkt
    }

    func testReset() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .testData)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 4)
        container.reset()
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 0)
    }
}
