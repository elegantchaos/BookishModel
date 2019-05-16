// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class GoogleLookupServiceTests: ModelTestCase {
    func testLookup() {
        let data: [String:Any] = ["items":
            [
                ["volumeInfo" : [
                    "title": "title",
                    "authors": ["author"],
                    "publisher": "publisher",
                    "publishedDate": "1969-11-12",
                    "imageLinks": [
                        "thumbnail": "image"
                        ]
                    ]
                ]
            ]
        ]
        
        let service = GoogleLookupService(name: "test")
        service.fetcher = TestDataFetcher(data: data)

        let done = expectation(description: "done")
        let container = makeTestContainer()
        let manager = LookupManager()
        manager.register(service: service)
        
        var candidate: LookupCandidate? = nil
        let session = manager.lookup(ean: "test", context: container.managedObjectContext) { (session, state) in
            switch state {
            case .done:
                done.fulfill()
                
            case .foundCandidate(let c):
                candidate = c
                
            default:
                break
            }
        }
        
        wait(for: [done], timeout: 1.0)

        guard let found = candidate else {
            XCTFail("candidate was nil")
            return
        }

        XCTAssertEqual(found.title, "title")
        XCTAssertEqual(found.authors, ["author"])
        XCTAssertEqual(found.publisher, "publisher")
        XCTAssertEqual(found.image, "image")
        XCTAssertEqual(found.action, "AddCandidate")
        XCTAssertEqual(found.summary, "title\nauthor\npublisher")
        XCTAssertEqual(session.context, container.managedObjectContext)
        
        let book = found.makeBook(in: container.managedObjectContext)
        XCTAssertEqual(book.name, "title")
        let relationships = book.relationships as? Set<Relationship>
        XCTAssertEqual(relationships?.first?.person?.name, "author")
        XCTAssertEqual(book.publisher?.name, "publisher")
        XCTAssertEqual(book.imageURL, "image")

    }
}
