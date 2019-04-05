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
    
    func makeSampleData(in url: URL) {
        let expectation = self.expectation(description: "import done")
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "Sample", withExtension: "xml")!
        let manager = ImportManager()
        let importer = DeliciousLibraryImporter(manager: manager)
        let container = makeTestContainer(name: "empty", url: url, mode: .empty)
        importer.run(importing: xmlURL, into: container.managedObjectContext) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        container.save()
        let baseURL = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let sourceURL = baseURL.appendingPathComponent("Sources").appendingPathComponent("BookishModel").appendingPathComponent("Resources").appendingPathComponent("Sample.bookish")
        try? FileManager.default.removeItem(at: sourceURL)
        try? FileManager.default.createDirectory(at: sourceURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try! FileManager.default.copyItem(at: url, to: sourceURL)
        let bookCount = container.managedObjectContext.countEntities(type: Book.self)
        print("Saved sample data to \(sourceURL) with \(bookCount) books.")
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

        // run the tests with `-makeSampleData YES` to re-import the sample database
        if UserDefaults.standard.bool(forKey: "makeSampleData") {
            makeSampleData(in: url)
        }

        let container = makeTestContainer(name: "test", url: url, mode: .sampleData)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 1505)
    }

    func testReset() {
        let url = temporaryFile()
        let container = makeTestContainer(name: "test", url: url, mode: .testData)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 4)
        container.reset()
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 0)
    }
}
