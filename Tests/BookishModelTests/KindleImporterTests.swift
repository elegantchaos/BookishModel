// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
import Actions

@testable import BookishModel

struct TestImportMonitor: ImportMonitor {
    func chooseFile(for importer: Importer, completion: @escaping (URL) -> Void) {
    }
    
    func session(_ session: ImportSession, willImportItems count: Int) {
    }
    
    func session(_ session: ImportSession, willImportItem item: Int, of count: Int) {
    }
    
    func sessionDidFinish(_ session: ImportSession) {
        expectation.fulfill()
    }
    
    func sessionDidFail(_ session: ImportSession) {
        expectation.fulfill()
    }
    
    func noImporter() {
        expectation.fulfill()
    }
    
    let expectation: XCTestExpectation
}

class KindleImporterTests: ModelTestCase {
    
//    func testImport() {
//        tagProcessorChannel.enabled = true
//        
//        let manager = ImportManager()
//        let importer = KindleImporter(manager: manager)
//        let container = makeTestContainer()
//
//        let expectation = self.expectation(description: "import done")
//        let bundle = Bundle(for: type(of: self))
//        let xmlURL = bundle.url(forResource: "KindleTest", withExtension: "xml")!
//        importer.run(importing: xmlURL, in: container.managedObjectContext, monitor: TestImportMonitor(expectation: expectation))
//        wait(for: [expectation], timeout: 10.0)
//        
//        let books: [Book] = Book.everyEntity(in: container.managedObjectContext, sorting: [NSSortDescriptor(key: "name", ascending: true)])
//        XCTAssertEqual(books.count, 3)
//        let titles = books.map { $0.name! }
//        
//        let expected = [
//            "A Big Ship at the Edge of the Universe (The Salvagers Book 1)",
//            "Places in the Darkness",
//            "Thin Air: From the author of Netflix's Altered Carbon (GOLLANCZ S.F.)",
//        ]
//
//
//        if titles != expected {
//            XCTFail("titles didn't match")
//            print("let expected = [")
//            for book in books {
//                print("\t\"\(book.name!)\",")
//            }
//            print("]")
//        }
//    }

}
