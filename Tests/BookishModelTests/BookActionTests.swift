// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


class BookActionTests: ModelActionTestCase, BookViewer, BookChangeObserver {
    var bookObserved: Book?

    func reveal(book: Book) {
        bookObserved = book
    }
    
    func added(books: [Book]) {
        bookObserved = books.first
    }

    func removed(books: [Book]) {
        bookObserved = books.first
    }
    
    func testNewBook() {
        info.addObserver(self)
        actionManager.perform(identifier: "NewBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 1)
        XCTAssertNotNil(bookObserved)
    }
    
    func testDeleteBooks() {
        let book = Book(context: context)
        XCTAssertEqual(count(of: "Book"), 1)
        
        info[ActionContext.selectionKey] = [book]
        info.addObserver(self)

        XCTAssertTrue(actionManager.validate(identifier: "DeleteBooks", info: info).enabled)

        actionManager.perform(identifier: "DeleteBooks", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 0)
        XCTAssertEqual(bookObserved, book)

        info[ActionContext.selectionKey] = []
        XCTAssertFalse(actionManager.validate(identifier: "DeleteBooks", info: info).enabled)
        
        XCTAssertFalse(actionManager.validate(identifier: "DeleteBooks", info: ActionInfo()).enabled)
    }
    
    
    func testRevealBook() {
        let book = Book(context: context)
        info[ActionContext.rootKey] = self
        info[BookAction.bookKey] = book
        XCTAssertTrue(actionManager.validate(identifier: "RevealBook", info: info).enabled)

        actionManager.perform(identifier: "RevealBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(bookObserved, book)
    }
}
