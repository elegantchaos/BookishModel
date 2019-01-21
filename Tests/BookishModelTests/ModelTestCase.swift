// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class ModelTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        modelChannel.enabled = true
    }
    
    func makeTestContainer() -> CollectionContainer {
        let url = URL(fileURLWithPath: "/dev/null")
        let collection = CollectionContainer(name: "Test", url: url, mode: .empty)
//        collection.configure(for: url)
        return collection
    }

    func check(book: Book, series: Series, position: Int) {
        let entry = (book.entries as? Set<SeriesEntry>)?.first
        XCTAssertEqual(entry?.series, series)
        XCTAssertEqual(entry?.position, Int16(position))
    }
    
    func check(book: Book, seriesName: String, position: Int) {
        let entry = (book.entries as? Set<SeriesEntry>)?.first
        XCTAssertEqual(entry?.series?.name, seriesName)
        XCTAssertEqual(entry?.position, Int16(position))
    }

    func check(relationship: Relationship, book: Book, person: Person) {
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(relationship.books?.count, 1)
        XCTAssertEqual(relationship.books?.allObjects.first as? Book, book)
        XCTAssertEqual(relationship.person, person)
    }
    
}
