// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Actions
import CoreData

@testable import BookishModel
//
//class LookupActionTests: ModelActionTestCase, BookViewer {
//    var viewed: Book? = nil
//    var revealed: XCTestExpectation? = nil
//    
//    class TestCandidate: LookupCandidate {
//        var madeBookCalled = false
//        var existingBookCalled = false
//        var book: Book? = nil
//        
//        init(book: Book? = nil) {
//            self.book = book
//            super.init(service: LookupService(name: "test"))
//        }
//
//        override var existingBook: Book? {
//            existingBookCalled = true
//            return book
//        }
//        
//        override func makeBook(in context: NSManagedObjectContext) -> Book {
//            madeBookCalled = true
//            return Book(in: context)
//        }
//    }
//    
//    func reveal(book: Book, dismissPopovers: Bool) {
//        viewed = book
//        revealed?.fulfill()
//    }
//    
//    func testLookupCover() {
//        class TestService: LookupService {
//            override func lookup(search: String, session: LookupSession) {
//                let candidate = LookupCandidate(service: self, title: "title", authors: ["author"], publisher: "publisher", date: Date(), image: "image")
//                session.add(candidate: candidate)
//                super.lookup(search: search, session: session)
//            }
//        }
//
//        // book starts off with no imageURL set, but a fake isbn which we can "look up" the image for
//        let book = Book(context: context)
//        book.isbn = "test"
//        XCTAssertNil(book.imageURL)
//
//        // watch for imageURL changing
//        let changed = expectation(description: "finished")
//        let observer = book.observe(\Book.imageURL) { (book, value) in
//            changed.fulfill()
//        }
//
//        // the action should not be valid unless there's a selection and manager set
//        XCTAssertFalse(actionManager.validate(identifier: "LookupCover", info: info).enabled)
//
//        // register our fake lookup service
//        let manager = LookupManager()
//        let service = TestService(name: "test")
//        manager.register(service: service)
//        
//        // perform the lookup
//        info[ActionContext.selectionKey] = [book]
//        info[LookupCoverAction.managerKey] = manager
//        XCTAssertTrue(actionManager.validate(identifier: "LookupCover", info: info).enabled)
//        actionManager.perform(identifier: "LookupCover", info: info)
//
//        // wait for something to happen
//        wait(for: [changed], timeout: 1.0)
//
//        // our fake service should now have filled in the imageURL
//        XCTAssertEqual(book.imageURL, "image")
//        
//        observer.invalidate()
//    }
//
//    func testViewCandidate() {
//        let book = Book(context: context)
//        let candidate = TestCandidate(book: book)
//        revealed = expectation(description: "revealed")
//
//        info[LookupAction.candidateKey] = candidate
//        info[ActionContext.rootKey] = self
//        actionManager.perform(identifier: "ViewCandidate", info: info)
//
//        wait(for: [revealed!], timeout: 1.0)
//        
//        XCTAssertTrue(candidate.existingBookCalled)
//        XCTAssertFalse(candidate.madeBookCalled)
//        XCTAssertEqual(book, viewed)
//    }
//    
//    func testAddCandidate() {
//        let candidate = TestCandidate()
//        revealed = expectation(description: "revealed")
//        
//        info[LookupAction.candidateKey] = candidate
//        info[ActionContext.rootKey] = self
//        actionManager.perform(identifier: "AddCandidate", info: info)
//        
//        wait(for: [revealed!], timeout: 1.0)
//        
//        XCTAssertFalse(candidate.existingBookCalled)
//        XCTAssertTrue(candidate.madeBookCalled)
//        XCTAssertNotNil(viewed)
//    }
//}
