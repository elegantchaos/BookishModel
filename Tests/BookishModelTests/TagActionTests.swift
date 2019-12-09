// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class TagActionTests: ModelActionTestCase, TagObserver {
    var tagsObserved: Set<Tag>?
    var otherTagsObserved: Set<Tag>?
    
    func renamed(tags: Set<Tag>) {
        tagsObserved = tags
    }
    
    func deleted(tags: Set<Tag>) {
        tagsObserved = tags
    }
    
    func changed(adding addedTags: Set<Tag>, removing removedTags: Set<Tag>) {
        tagsObserved = addedTags
        otherTagsObserved = removedTags
    }
    
    func testDeleteTag() {
//        let tag = Tag(context: context)
//        XCTAssertEqual(count(of: "Tag"), 1)
//
//        info.addObserver(self)
//        info[TagAction.tagKey] = tag
//        XCTAssertTrue(actionManager.validate(identifier: "DeleteTag", info: info).enabled)
//        actionManager.perform(identifier: "DeleteTag", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Tag"), 0)
//        XCTAssertNotNil(tagsObserved)
    }
    
    func testRenameTag() {
//        let tag = Tag(context: context)
//        tag.name = "foo"
//        XCTAssertEqual(count(of: "Tag"), 1)
//
//        info.addObserver(self)
//        info[TagAction.tagKey] = tag
//        info[TagAction.tagNameKey] = "bar"
//        XCTAssertTrue(actionManager.validate(identifier: "RenameTag", info: info).enabled)
//        actionManager.perform(identifier: "RenameTag", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(tag.name, "bar")
//        XCTAssertNotNil(tagsObserved)
    }
    
    func testChangeTags() {
//        let book = Book(context: context)
//        let tag1 = Tag(context: context)
//        tag1.name = "foo"
//        
//        let tag2 = Tag(context: context)
//        tag2.name = "bar"
//        XCTAssertEqual(count(of: "Tag"), 2)
//        
//        tag1.addToBooks(book)
//
//        info.addObserver(self)
//        info[TagAction.addedTagsKey] = Set<Tag>([tag2])
//        info[TagAction.removedTagsKey] = Set<Tag>([tag1])
//        info[ActionContext.selectionKey] = [book]
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeTags", info: info).enabled)
//        actionManager.perform(identifier: "ChangeTags", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(book.tags.first?.name, "bar")
//        XCTAssertNotNil(tagsObserved)
//        XCTAssertNotNil(otherTagsObserved)
    }

    func testTagCoverage() {
        // call the placeholders so that they don't mess up the coverage results
        struct Dummy: TagObserver { }
        let dummy = Dummy()
        dummy.changed(adding: [], removing: [])
        dummy.renamed(tags: [])
        dummy.deleted(tags: [])
    }
}
