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
        let collection = CollectionContainer(name: "Test", url: url, mode: .empty, indexed: false)
//        collection.configure(for: url)
        return collection
    }

    func check(book: Book, series: Series, position: Int, ignore: SeriesEntry? = nil) -> Bool {
        guard let entries = book.entries as? Set<SeriesEntry> else {
            return false
        }

        for entry in entries {
            if entry == ignore {
                continue
            }

            XCTAssertEqual(entry.series, series)
            XCTAssertEqual(entry.position, Int16(position))
            return (entry.series == series) && (entry.position == Int16(position))
        }
        
        return false
    }
    
    func check(book: Book, seriesName: String, position: Int, ignore: SeriesEntry? = nil) -> Bool {
        guard let entries = book.entries as? Set<SeriesEntry> else {
            return false
        }
        
        for entry in entries {
            if entry == ignore {
                continue
            }
            
            XCTAssertEqual(entry.series?.name, seriesName)
            XCTAssertEqual(entry.position, Int16(position))
            return (entry.series!.name == seriesName) && (entry.position == Int16(position))
        }
        
        return false
    }

    func check(relationship: Relationship, book: Book, person: Person) {
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(relationship.books.count, 1)
        XCTAssertEqual(relationship.books.first, book)
        XCTAssertEqual(relationship.person, person)
    }
    
}
