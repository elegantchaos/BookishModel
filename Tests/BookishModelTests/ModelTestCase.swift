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
        let container = CollectionContainer(name: "Collection")
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }
        return container
    }

}
