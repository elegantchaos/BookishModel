// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class ImporterTests: ModelTestCase {

    func testImporter() {
        let url = temporaryFile()
        let expectation = self.expectation(description: "import done")
        let container = CollectionContainer(name: "test", url: url, mode: .empty) { (container, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(container)

            let manager = ImportManager()
            let importer = DeliciousLibraryImporter(manager: manager)
            let bundle = Bundle(for: type(of: self))
            let xmlURL = bundle.url(forResource: "Simple", withExtension: "plist")!
            importer.run(importing: xmlURL, into: container.managedObjectContext) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(container.managedObjectContext.countEntities(type: Book.self), 2)
    }

}
