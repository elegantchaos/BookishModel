// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class BookTests: ModelTestCase {
    func testAllBooks() {
    let container = makeTestContainer()
    let context = container.viewContext
    let b1 = Book(context: context)
    let b2 = Book(context: context)
    let allBooks: [Book] = context.everyEntity()
    XCTAssertEqual(allBooks.count, 2)
    XCTAssertTrue(allBooks.contains(b1))
    XCTAssertTrue(allBooks.contains(b2))

    }
}
