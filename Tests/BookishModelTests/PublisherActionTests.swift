// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class PublisherActionTests: ModelActionTestCase, PublisherViewer, PublisherLifecycleObserver {
    var publisherObserved: Publisher?
    
    func created(publisher: Publisher) {
        publisherObserved = publisher
    }
    
    func deleted(publisher: Publisher) {
        publisherObserved = publisher
    }
    
    func reveal(publisher: Publisher) {
        publisherObserved = publisher
    }
    
    func testNewPublisher() {
        info.addObserver(self)
        XCTAssertTrue(actionManager.validate(identifier: "NewPublisher", info: info).enabled)
        actionManager.perform(identifier: "NewPublisher", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Publisher"), 1)
        XCTAssertNotNil(publisherObserved)
    }
    
    func testDeletePublishers() {
        let publisher = Publisher(context: context)
        XCTAssertEqual(count(of: "Publisher"), 1)

        XCTAssertFalse(actionManager.validate(identifier: "DeletePublisher", info: info).enabled)

        info.addObserver(self)
        info[ActionContext.selectionKey] = [publisher]
        
        XCTAssertTrue(actionManager.validate(identifier: "DeletePublisher", info: info).enabled)
        actionManager.perform(identifier: "DeletePublisher", info: info)
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(count(of: "Publisher"), 0)
        XCTAssertEqual(publisherObserved, publisher)
        info[ActionContext.selectionKey] = []
        XCTAssertFalse(actionManager.validate(identifier: "DeletePublisher", info: info).enabled)

        info[ActionContext.selectionKey] = [Book(context: context)]
        XCTAssertFalse(actionManager.validate(identifier: "DeletePublisher", info: info).enabled)

        info[ActionContext.selectionKey] = [Book(context: context)]
        XCTAssertFalse(actionManager.validate(identifier: "DeletePublisher", info: ActionInfo()).enabled)

    }
    
    func testRevealPublisher() {
        let publisher = Publisher(context: context)
        info[ActionContext.rootKey] = self
        info[PublisherAction.newPublisherKey] = publisher

        XCTAssertTrue(actionManager.validate(identifier: "RevealPublisher", info: info).enabled)
        actionManager.perform(identifier: "RevealPublisher", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publisherObserved, publisher)
    }
    
}
