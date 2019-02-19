// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
import Actions

@testable import BookishModel

class ImporterTests: ModelTestCase {
    
    class DummyImporter: Importer {
        override var defaultImportLocation: URL { return URL(fileURLWithPath: "/test") }
    }
    
    func testRegistration() {
        let manager = ImportManager()
        let i1 = Importer(name: "test", source: .knownLocation, manager: manager)
        let i2 = Importer(name: "test2", source: .userSpecifiedFile, manager: manager)
        manager.register(importer: i1)
        manager.register(importer: i2)
        XCTAssertTrue(manager.importer(named: "test") === i1)
        XCTAssertTrue(manager.importer(named: "test2") === i2)
        XCTAssertEqual(manager.sortedImporters.count, 3)
        XCTAssertTrue(manager.sortedImporters[1] === i1)
    }
    
    func testDefaultsKnownLocation() {
        let manager = ImportManager()
        let importer = DummyImporter(name: "test", source: .knownLocation, manager: manager)
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
            let importer = manager.importer(named: "Delicious Library")!
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
            info[ImportAction.importerKey] = "Delicious Library"
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
