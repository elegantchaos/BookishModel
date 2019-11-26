// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import XCTest

@testable import BookishModel

class ImporterTests: ModelTestCase {
    
    class DummyImporter1: Importer {
        override class var identifier: String { return "dummy1" }
        override var defaultImportLocation: URL { return URL(fileURLWithPath: "/test") }
    }

    class DummyImporter2: DummyImporter1 {
        override class var identifier: String { return "dummy2" }
    }

    class Monitor: ImportMonitor {
        enum Status {
            case unknown
            case failed
            case ok
        }
        
        typealias Checker = (Datastore, Monitor) -> Void
        var status: Status = .unknown
        let expectation: XCTestExpectation
        let checker: Checker
        
        init(expectation: XCTestExpectation, checker: @escaping Checker) {
            self.expectation = expectation
            self.checker = checker
        }
        
        func sessionDidFinish(_ session: ImportSession) {
            checker(session.store, self)
        }
        
        func sessionDidFail(_ session: ImportSession) {
            XCTFail("import failed")
            expectation.fulfill()
        }

        func noImporter() {
            XCTFail("no importer found")
            expectation.fulfill()
        }
        
        func checkPassed() {
            if status == .unknown {
                status = .ok
                self.expectation.fulfill()
            }
        }
        
        func checkFailed() {
            if status == .unknown {
                status = .failed
                expectation.fulfill()
            }
        }
        
        func check(count: Int, expected: Int) {
            if status == .unknown {
                if count != expected {
                    status = .failed
                    XCTFail("\(count) != \(expected)")
                    expectation.fulfill()
                }
            }
        }
    }

    func check(importing url: URL, with importer: Importer, checker: @escaping Monitor.Checker) -> Bool {
        let expectation = self.expectation(description: "completed")
        let monitor = Monitor(expectation: expectation, checker: checker)
        Datastore.load(name: "Test") { result in
            switch result {
            case .failure(let error):
                XCTFail("failed to make store: \(error)")
                expectation.fulfill()
            case .success(let store):
                importer.run(importing: url, in: store, monitor: monitor)
            }
        }

        wait(for: [expectation], timeout: 10.0)
        return monitor.status == .ok
    }
    
    func testRegistration() {
        let manager = ImportManager()
        let initialCount = manager.sortedImporters.count
        let i1 = DummyImporter1(name: "A test 1", source: .knownLocation, manager: manager)
        let i2 = DummyImporter2(name: "Z test 2", source: .userSpecifiedFile, manager: manager)
        manager.register([i1, i2])
        XCTAssertTrue(manager.importer(identifier: "dummy1") === i1)
        XCTAssertTrue(manager.importer(identifier: "dummy2") === i2)
        XCTAssertEqual(manager.sortedImporters.count, initialCount + 2)
        XCTAssertTrue(manager.sortedImporters[0] === i1)
        XCTAssertTrue(manager.sortedImporters[initialCount + 1] === i2)
    }
    
    func testDefaultsKnownLocation() {
        let manager = ImportManager()
        let importer = DummyImporter1(name: "test", source: .knownLocation, manager: manager)
        XCTAssertFalse(importer.canImport)
        XCTAssertEqual(importer.defaultImportLocation.path, "/test")
    }

    func testDefaultsUserSpecified() {
        let manager = ImportManager()
        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
        XCTAssertTrue(importer.canImport)
        XCTAssertNil(importer.defaultImportLocation)
    }

    func testImporter() {
        let manager = ImportManager()
        let importer = manager.importer(identifier: DeliciousLibraryImporter.identifier)!
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "Simple", withExtension: "plist")!
        XCTAssertTrue(check(importing: xmlURL, with: importer, checker: { store, monitor in
            store.get(allEntitiesOfType: "Book") { result in
                monitor.check(count: result.count, expected: 2)
                monitor.checkPassed()
            }
        }))
    }
//
//    func testImportAction() {
//        let url = URL(fileURLWithPath: "/dev/null")
//        let expectation = self.expectation(description: "import done")
//        let container = CollectionContainer(name: "test", url: url, mode: .empty, indexed: false) { (container, error) in
//            XCTAssertNil(error)
//            XCTAssertNotNil(container)
//
//            let actionManager = ActionManager()
//            actionManager.register([ImportAction(identifier: "Import")])
//
//            let manager = ImportManager()
//            let xmlURL = Bundle(for: type(of: self)).url(forResource: "Simple", withExtension: "plist")!
//            let info = ActionInfo()
//            info[ImportAction.managerKey] = manager
//            info[ImportAction.urlKey] = xmlURL
//            info[ImportAction.importerKey] = DeliciousLibraryImporter.identifier
//            info[ActionContext.modelKey] = container.managedObjectContext
//            info.registerNotification(notification: { (stage, context) in
//                if stage == .didPerform {
//                    expectation.fulfill()
//                }
//            })
//
//            actionManager.perform(identifier: "Import", info: info)
//        }
//        wait(for: [expectation], timeout: 10.0)
//        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 2)
//    }
//
//    func testFileTypes() {
//        let manager = ImportManager()
//        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
//        XCTAssertNil(importer.fileTypes)
//    }
//
//    func testPanelPrompt() {
//        let manager = ImportManager()
//        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
//        XCTAssertEqual(importer.panelPrompt, "importer.prompt")
//    }
//
//    func testPanelMessage() {
//        let manager = ImportManager()
//        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
//        XCTAssertEqual(importer.panelMessage, "importer.message")
//    }
//
//    func testStandardRolesImporter() {
//        let container = makeTestContainer()
//        let manager = ImportManager()
//        let importer = StandardRolesImporter(manager: manager)
//        manager.register([importer])
//        let expectation = self.expectation(description: "completed")
//        importer.run(in: container.managedObjectContext, monitor: TestImportMonitor(expectation: expectation))
//        wait(for: [expectation], timeout: 1.0)
//        let count = container.managedObjectContext.countEntities(type: Role.self)
//        XCTAssertEqual(count, Role.StandardName.allCases.count)
//    }
//
//    func testTestDataImporter() {
//        let container = makeTestContainer()
//        let manager = ImportManager()
//        let importer = TestDataImporter(manager: manager)
//        manager.register([importer])
//        let expectation = self.expectation(description: "completed")
//        importer.run(in: container.managedObjectContext, monitor: TestImportMonitor(expectation: expectation))
//        wait(for: [expectation], timeout: 1.0)
//        let roles = container.managedObjectContext.countEntities(type: Role.self)
//        XCTAssertEqual(roles, Role.StandardName.allCases.count)
//        let books = container.managedObjectContext.countEntities(type: Book.self)
//        XCTAssertEqual(books, 4)
//    }
}
