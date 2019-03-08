// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel

class PersonTests:ModelTestCase {
    
    func testPersonNamedExists() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        person.name = "Test"
        
        let person2 = Person.named("Test", in: context)
        XCTAssertTrue(person === person2)
    }
    
    func testPersonNamedDoesntExist() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person.named("Test", in: context)
        XCTAssertEqual(person.name, "Test")
    }

    func testPersonNamedDoesntExistDontCreate() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person.named("Test", in: context, createIfMissing: false)
        XCTAssertNil(person)
    }

    func testAllPeople() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person1 = Person(context: context)
        let person2 = Person(context: context)
        let allPeople: [Person] = context.everyEntity()
        XCTAssertEqual(allPeople.count, 2)
        XCTAssertTrue(allPeople.contains(person1))
        XCTAssertTrue(allPeople.contains(person2))
    }
    
    func testSectionName() {
        let container = makeTestContainer()
        let context = container.managedObjectContext
        let person = Person(context: context)
        person.name = "Foo Bar"
        XCTAssertEqual(person.sectionName, "B")
    }
}
