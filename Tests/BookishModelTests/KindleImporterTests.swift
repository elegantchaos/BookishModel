// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
import Actions

@testable import BookishModel

class KindleImporterTests: ModelTestCase {
    func testImport() {
        let manager = ImportManager()
        let importer = KindleImporter(manager: manager)
        let container = makeTestContainer()

        let expectation = self.expectation(description: "import done")
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "KindleSyncMetadataCache", withExtension: "xml")!
        importer.run(importing: xmlURL, into: container.managedObjectContext) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

}
