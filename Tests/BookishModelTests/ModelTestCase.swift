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
    
    func makeTestContainer() -> BookishCollection {
        let url = URL(fileURLWithPath: "/dev/null")
        let collection = BookishCollection(url: url)
//        collection.configure(for: url)
        return collection
    }

}
