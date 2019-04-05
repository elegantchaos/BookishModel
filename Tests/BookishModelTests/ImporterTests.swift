// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
import Actions

@testable import BookishModel

class ImporterTests: ModelTestCase {
    
    class DummyImporter1: Importer {
        override class var identifier: String { return "dummy1" }
        override var defaultImportLocation: URL { return URL(fileURLWithPath: "/test") }
    }

    class DummyImporter2: DummyImporter1 {
        override class var identifier: String { return "dummy2" }
    }

    func testRegistration() {
        let manager = ImportManager()
        let i1 = DummyImporter1(name: "test1", source: .knownLocation, manager: manager)
        let i2 = DummyImporter2(name: "test2", source: .userSpecifiedFile, manager: manager)
        manager.register([i1, i2])
        XCTAssertTrue(manager.importer(identifier: "dummy1") === i1)
        XCTAssertTrue(manager.importer(identifier: "dummy2") === i2)
        XCTAssertEqual(manager.sortedImporters.count, 4)
        XCTAssertTrue(manager.sortedImporters[2] === i1)
    }
    
    func testDefaultsKnownLocation() {
        let manager = ImportManager()
        let importer = DummyImporter1(name: "test", source: .knownLocation, manager: manager)
        XCTAssertFalse(importer.canImport)
        XCTAssertEqual(importer.defaultImportLocation.path, "/test")
        
        let expectation = self.expectation(description: "completed")
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        importer.run(importing: URL(fileURLWithPath: "/test"), into: context) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDefaultsUserSpecified() {
        let manager = ImportManager()
        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
        XCTAssertTrue(importer.canImport)
        XCTAssertNil(importer.defaultImportLocation)
    }

    func testImporter() {
        let url = temporaryFile()
        let expectation = self.expectation(description: "import done")
        let container = CollectionContainer(name: "test", url: url, mode: .empty) { (container, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(container)

            let manager = ImportManager()
            let importer = manager.importer(identifier: DeliciousLibraryImporter.identifier)!
            let bundle = Bundle(for: type(of: self))
            let xmlURL = bundle.url(forResource: "Simple", withExtension: "plist")!
            importer.run(importing: xmlURL, into: container.managedObjectContext) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 2)
    }

    func testImportAction() {
        let url = temporaryFile()
        let expectation = self.expectation(description: "import done")
        let container = CollectionContainer(name: "test", url: url, mode: .empty) { (container, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(container)

            let actionManager = ActionManager()
            actionManager.register([ImportAction(identifier: "Import")])
            
            let manager = ImportManager()
            let xmlURL = Bundle(for: type(of: self)).url(forResource: "Simple", withExtension: "plist")!
            let info = ActionInfo()
            info[ImportAction.managerKey] = manager
            info[ImportAction.urlKey] = xmlURL
            info[ImportAction.importerKey] = DeliciousLibraryImporter.identifier
            info[ActionContext.modelKey] = container.managedObjectContext
            info.registerNotification(notification: { (stage, context) in
                if stage == .didPerform {
                    expectation.fulfill()
                }
            })

            actionManager.perform(identifier: "Import", info: info)
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 2)
    }
}
