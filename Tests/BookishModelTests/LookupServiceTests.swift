// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import BookishModel

class LookupServiceTests: ModelTestCase {
    
    func testRegistration() {
        class TestService: LookupService {
            let started: XCTestExpectation
            let finished: XCTestExpectation
            let found: XCTestExpectation
            let date = Date()
            var lookedUp: String = ""
            var candidate: LookupCandidate?
            
            init(test: XCTestCase) {
                started = test.expectation(description: "started")
                found = test.expectation(description: "found")
                finished = test.expectation(description: "finished")
                super.init(name: "test")
            }
            
            func update(state: LookupSession.State) {
                switch state {
                case .starting:
                    started.fulfill()
                    
                case .foundCandidate(let candidate):
                    self.candidate = candidate
                    found.fulfill()
                    
                case .done:
                    finished.fulfill()
                    
                default:
                    break
                }
            }
            
            func wait(test: XCTestCase) {
                test.wait(for: [started, found, finished], timeout: 1.0)
            }
            
            override func lookup(search: String, session: LookupSession) {
                lookedUp = search
                let candidate = LookupCandidate(service: self, title: "title", authors: ["author"], publisher: "publisher", date: date, image: "image")
                session.add(candidate: candidate)
                super.lookup(search: search, session: session)
            }
        }

        let collection = makeTestContainer()
        let manager = LookupManager()
        let service = TestService(test: self)
        manager.register(service: service)
        let session = manager.lookup(ean: "test", collection: collection) { (session, state) in
            service.update(state: state)
        }
        
        service.wait(test: self)
        
        XCTAssertEqual(session.search, "test")
        XCTAssertEqual(service.lookedUp, "test")
        XCTAssertEqual(service.candidate?.title, "title")
        XCTAssertEqual(service.candidate?.authors, ["author"])
        XCTAssertEqual(service.candidate?.publisher, "publisher")
        XCTAssertEqual(service.candidate?.date, service.date)
    }

    func testFailure() {
        class FailingService: LookupService {
            let started: XCTestExpectation
            let finished: XCTestExpectation
            let failed: XCTestExpectation
            
            init(test: XCTestCase) {
                started = test.expectation(description: "started")
                failed = test.expectation(description: "failed")
                finished = test.expectation(description: "finished")
                super.init(name: "test")
            }
            
            func update(state: LookupSession.State) {
                switch state {
                case .starting:
                    started.fulfill()
                    
                case .failed:
                    failed.fulfill()
                    
                case .done:
                    finished.fulfill()
                    
                default:
                    break
                }
            }
            
            func wait(test: XCTestCase) {
                test.wait(for: [started, failed, finished], timeout: 1.0)
            }
            
            override func lookup(search: String, session: LookupSession) {
                session.failed(service: self)
            }
        }
        
        let collection = makeTestContainer()
        let manager = LookupManager()
        let service = FailingService(test: self)
        manager.register(service: service)
        let session = manager.lookup(ean: "test", collection: collection) { (session, state) in
            service.update(state: state)
        }
        
        service.wait(test: self)
        XCTAssertEqual(session.search, "test")
    }
    
    func testCancellation() {
        class CancellableService: LookupService {
            let cancelled: XCTestExpectation
            let started: XCTestExpectation
            
            init(test: XCTestCase) {
                cancelled = test.expectation(description: "cancelled")
                started = test.expectation(description: "started")
                super.init(name: "test")
            }
            
            func update(state: LookupSession.State) {
                switch state {
                case .starting:
                    started.fulfill()
                    
                default:
                    break
                }
            }
            
            func wait(test: XCTestCase) {
                test.wait(for: [started, cancelled], timeout: 1.0)
            }
            
            override func lookup(search: String, session: LookupSession) {
                // doing nothing here will cause the service to never stop running
            }
            
            override func cancel() {
                cancelled.fulfill()
                super.cancel()
            }
        }
        
        let collection = makeTestContainer()
        let manager = LookupManager()
        let service = CancellableService(test: self)
        manager.register(service: service)
        let session = manager.lookup(ean: "test", collection: collection) { (session, state) in
            service.update(state: state)
            session.cancel()
        }
        
        service.wait(test: self)
        XCTAssertEqual(session.search, "test")
    }
    
    func testMaking() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let service = LookupService(name: "test")
        let now = Date()
        let authorNames = ["a", "b"]
        let candidate = LookupCandidate(service: service, title: "title", authors: authorNames, publisher: "publisher", date: now, image: "image")
        let book = candidate.makeBook(in: context)
        
        XCTAssertEqual(context.countEntities(type: Book.self), 1)
        XCTAssertEqual(context.countEntities(type: Person.self), 2)
        XCTAssertEqual(context.countEntities(type: Publisher.self), 1)

        XCTAssertEqual(book.name, "title")
        XCTAssertEqual(book.publisher!.name, "publisher")
        XCTAssertEqual(book.imageURL, "image")

        let relationships = book.relationships as! Set<Relationship>
        for relationship in relationships {
            XCTAssertTrue(authorNames.contains(relationship.person!.name!))
        }
    }
    
    func testNoServices() {
        let collection = makeTestContainer()
        let started = expectation(description: "started")
        let finished = expectation(description: "finished")
        let manager = LookupManager()
        let session = manager.lookup(ean: "test", collection: collection) { (session, state) in
            switch state {
            case .starting:
                started.fulfill()
            case .done:
                finished.fulfill()
            default:
                break
            }
        }
        
        wait(for: [started, finished], timeout: 1.0)
        XCTAssertEqual(session.search, "test")

    }
    
    func testExistingCollectionLookup() {
        let done = expectation(description: "done")
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let service = ExistingCollectionLookupService(name: "test")
        let manager = LookupManager()
        manager.register(service: service)
        
        var candidate: LookupCandidate? = nil
        let book = Book.named("Test Book", in: context)
        let testEAN = "12345678"
        book.ean = testEAN

        let session = manager.lookup(ean: testEAN, collection: container) { (session, state) in
            switch state {
            case .done:
                done.fulfill()
                
            case .foundCandidate(let c):
                candidate = c
                
            default:
                break
            }
        }
                
        wait(for: [done], timeout: 1.0)
        XCTAssertNotNil(candidate)
        XCTAssertEqual(session.search, testEAN)
    }
    
    func testCandidateSummary() {
        let service = ExistingCollectionLookupService(name: "test")
        XCTAssertEqual(LookupCandidate(service: service, authors:["Foo"]).summary, "")
    }
}
