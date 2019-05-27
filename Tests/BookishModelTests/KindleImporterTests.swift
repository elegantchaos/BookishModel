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
        tagProcessorChannel.enabled = true
        
        let manager = ImportManager()
        let importer = KindleImporter(manager: manager)
        let container = makeTestContainer()

        let expectation = self.expectation(description: "import done")
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "KindleTest", withExtension: "xml")!
        importer.run(importing: xmlURL, in: container.managedObjectContext) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        let books: [Book] = container.managedObjectContext.everyEntity(sorting: [NSSortDescriptor(key: "name", ascending: true)])
        XCTAssertEqual(books.count, 3)
        let titles = books.map { $0.name! }
        
        let expected = [
            "A Big Ship at the Edge of the Universe (The Salvagers Book 1)",
            "Places in the Darkness",
            "Thin Air: From the author of Netflix's Altered Carbon (GOLLANCZ S.F.)",
        ]


        if titles != expected {
            XCTFail("titles didn't match")
            print("let expected = [")
            for book in books {
                print("\t\"\(book.name!)\",")
            }
            print("]")
        }
    }

}
