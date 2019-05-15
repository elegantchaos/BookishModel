// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Actions
@testable import BookishModel

class LookupActionTests: ModelActionTestCase {
    func testLookupCover() {
        class TestService: LookupService {
            override func lookup(search: String, session: LookupSession) {
                let candidate = LookupCandidate(service: self, title: "title", authors: ["author"], publisher: "publisher", date: Date(), image: "image")
                session.add(candidate: candidate)
                super.lookup(search: search, session: session)
            }
        }

        // book starts off with no imageURL set, but a fake isbn which we can "look up" the image for
        let book = Book(context: context)
        book.isbn = "test"
        XCTAssertNil(book.imageURL)

        // watch for imageURL changing
        let changed = expectation(description: "finished")
        let observer = book.observe(\Book.imageURL) { (book, value) in
            changed.fulfill()
        }

        // the action should not be valid unless there's a selection and manager set
        XCTAssertFalse(actionManager.validate(identifier: "LookupCover", info: info).enabled)

        // register our fake lookup service
        let manager = LookupManager()
        let service = TestService(name: "test")
        manager.register(service: service)
        
        // perform the lookup
        info[ActionContext.selectionKey] = [book]
        info[LookupCoverAction.managerKey] = manager
        XCTAssertTrue(actionManager.validate(identifier: "LookupCover", info: info).enabled)
        actionManager.perform(identifier: "LookupCover", info: info)

        // wait for something to happen
        wait(for: [changed], timeout: 1.0)

        // our fake service should now have filled in the imageURL
        XCTAssertEqual(book.imageURL, "image")
        
        observer.invalidate()
    }

}
