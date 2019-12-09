// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import XCTest
import XCTestExtensions

@testable import BookishModel
@testable import Actions

class ImporterTests: ModelTestCase {
    
    class DummyImporter1: Importer {
        override class var identifier: String { return "dummy1" }
        override var defaultImportLocation: URL { return URL(fileURLWithPath: "/test") }
    }

    class DummyImporter2: DummyImporter1 {
        override class var identifier: String { return "dummy2" }
    }

 
    func check(importing url: URL? = nil, with importerID: String, checker: @escaping StoreMonitor.Checker) -> Bool {
        let manager = ImportManager()
        let importer = manager.importer(identifier: importerID)!
        let result = checkStore() { monitor in
            let delegate = BlockImportDelegate()
            delegate.didFinishBlock = { status in
                checker(monitor)
            }
            if let url = url {
                importer.run(importing: url, in: monitor.store, monitor: delegate)
            } else {
                importer.run(in: monitor.store, monitor: delegate)
            }
        }
        
        return result
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

    func testDeliciousImporter() {
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "Simple", withExtension: "plist")!
        XCTAssertTrue(check(importing: xmlURL, with: DeliciousLibraryImporter.identifier, checker: { monitor in
            let store = monitor.store
            store.get(allEntitiesOfType: .book) { books in
                monitor.check(count: books.count, expected: 2)
                store.get(properties: [.name], of: books) { result in
                    let names = Set<String>(result.compactMap({ $0["name"] as? String }))
                    XCTAssertTrue(names.contains("The Bridge"))
                    XCTAssertTrue(names.contains("A Dance With Dragons: Part 1 Dreams and Dust"))
                    let book = Entity.identifiedBy("FAB4A0CF-9DEE-41B3-BA64-2FE5335F389E")
                    store.get(allPropertiesOf: [book]) { result in
                        monitor.check(count: result.count, expected: 1)
                        let bookProperties = result[0]
                        print(bookProperties)
                        XCTAssertEqual((bookProperties[.published] as? Date)?.timeIntervalSinceReferenceDate, 353462400.0)
                        
                        let publisher = bookProperties[.publisher] as! EntityReference
                        store.get(allPropertiesOf: [publisher]) { results in
                            monitor.check(count: results.count, expected: 1)
                            let publisherProperties = results[0]
                            XCTAssertEqual(publisherProperties[.name] as? String, "Harper Voyager")
                            monitor.allChecksDone()
                        }
                    }
                }
            }
        }))
    }
    

    func testStandardRolesImporter() {
        XCTAssertTrue(check(with: StandardRolesImporter.identifier, checker: { monitor in
            monitor.store.count(entitiesOfTypes: [.role]) { counts in
                monitor.check(count: counts[0], expected: Role.StandardName.allCases.count)
                monitor.allChecksDone()
            }
        }))
    }
    
    
    func testTestDataImporter() {
        XCTAssertTrue(check(with: TestDataImporter.identifier, checker: { monitor in
            monitor.store.count(entitiesOfTypes: [.role, .book]) { counts in
                monitor.check(count: counts[0], expected: Role.StandardName.allCases.count)
                monitor.check(count: counts[1], expected: 4)
                monitor.allChecksDone()
            }
        }))
    }
    

    func testFileTypes() {
        let manager = ImportManager()
        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
        XCTAssertNil(importer.fileTypes)
    }

    func testPanelPrompt() {
        let manager = ImportManager()
        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
        XCTAssertEqual(importer.panelPrompt, "importer.prompt")
    }

    func testPanelMessage() {
        let manager = ImportManager()
        let importer = Importer(name: "test", source: .userSpecifiedFile, manager: manager)
        XCTAssertEqual(importer.panelMessage, "importer.message")
    }
}

class ImporterActionTests: ModelActionTestCase {
    
    func testImportAction() {
        let xmlURL = Bundle(for: type(of: self)).url(forResource: "Simple", withExtension: "plist")!
        let manager = ImportManager()
        let info = ActionInfo()
        info[ImportAction.managerKey] = manager
        info[ImportAction.urlKey] = xmlURL
        info[ImportAction.importerKey] = DeliciousLibraryImporter.identifier

        XCTAssertTrue(checkAction(ImportAction(), withInfo: info) { monitor in
            let store = monitor.wrappedMonitor.container.store
            store.count(entitiesOfTypes: [.book]) { counts in
                monitor.check(count: counts[0], expected: 2)
                monitor.allChecksDone()
            }
        })
    }

}
