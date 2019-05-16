// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class GoogleLookupServiceTests: ModelTestCase {
    func googleResult(isbnType: String? = nil, isbn: String? = nil) -> [String:Any] {
        var volumeInfo: [String:Any] = [
            "title": "title",
            "authors": ["author"],
            "publisher": "publisher",
            "publishedDate": "1969-11-12",
            "pageCount": 1234,
            "imageLinks": [
                "thumbnail": "image"
            ],
        ]
        
        if let type = isbnType, let value = isbn {
            volumeInfo["industryIdentifiers"] = [
                ["type": type, "identifier": value],
            ]
        }

        let data: [String:Any] = ["items":
            [
                ["volumeInfo" : volumeInfo]
            ]
        ]
        
        return data
    }
    
    func check(data: [String:Any], expectedISBN: String? = nil) -> Bool {
        let service = GoogleLookupService(name: "test")
        service.fetcher = TestDataFetcher(data: data)
        
        let done = expectation(description: "done")
        let container = makeTestContainer()
        let manager = LookupManager()
        manager.register(service: service)
        
        var candidate: LookupCandidate? = nil
        let session = manager.lookup(ean: expectedISBN ?? "blah", context: container.managedObjectContext) { (session, state) in
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
            return false
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
        XCTAssertEqual(book.pages, 1234)
        XCTAssertEqual(book.isbn, expectedISBN)

        return true
    }
    
    func testLookupISBN13() {
        let data = googleResult(isbnType: "ISBN_13", isbn: "9781509860142")
        XCTAssertTrue(check(data: data, expectedISBN: "9781509860142"))
    }

    func testLookupISBN10() {
        let data = googleResult(isbnType: "ISBN_10", isbn: "1509860142")
        XCTAssertTrue(check(data: data, expectedISBN: "9781509860142"))
    }

    func testLookupNoISBN() {
        let data = googleResult(isbnType: "blah", isbn: "blah")
        XCTAssertTrue(check(data: data))
    }
    
    func testLookupFailure() {
        XCTAssertFalse(check(data: [:]))
    }
}
