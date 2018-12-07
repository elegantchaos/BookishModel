// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


class BookActionTests: ModelActionTestCase, BookViewer {
    var bookRevealed: Book?

    func reveal(book: Book) {
        bookRevealed = book
    }
    

    func testNewBook() {
        actionManager.perform(identifier: "NewBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 1)
    }
    
    func testDeleteBooks() {
        let book = Book(context: context)
        XCTAssertEqual(count(of: "Book"), 1)
        
        info[ActionContext.selectionKey] = [book]
        
        actionManager.perform(identifier: "DeleteBooks", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 0)
    }
    
    func testRevealBook() {
        let book = Book(context: context)
        info[ActionContext.rootKey] = self
        info[BookAction.bookKey] = book
        actionManager.perform(identifier: "RevealBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRevealed, book)
    }
    
}
