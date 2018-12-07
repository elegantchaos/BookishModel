// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions

class PublisherActionTests: ModelActionTestCase, PublisherViewer {
    var publisherRevealed: Publisher?
    
    func reveal(publisher: Publisher) {
        publisherRevealed = publisher
    }
    
    func testNewPublisher() {
        actionManager.perform(identifier: "NewPublisher", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Publisher"), 1)
    }
    
    func testDeletePublishers() {
        let series = Publisher(context: context)
        XCTAssertEqual(count(of: "Publisher"), 1)
        
        info[ActionContext.selectionKey] = [series]
        
        actionManager.perform(identifier: "DeletePublisher", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Publisher"), 0)
    }
    
    func testRevealPublisher() {
        let publisher = Publisher(context: context)
        info[ActionContext.rootKey] = self
        info[PublisherAction.publisherKey] = publisher
        actionManager.perform(identifier: "RevealPublisher", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publisherRevealed, publisher)
    }
    
}
