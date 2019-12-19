// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 16/12/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions
import Datastore

class BookActionTests: ModelActionTestCase, EntityViewer {
    var entityObserved: EntityReference?

    func reveal(entity: EntityReference, dismissPopovers: Bool) {
        entityObserved = entity
    }
        
    func testAddRelationshipValidation() {
        let book = Book(named: "Test")
        let info = ActionInfo()
        let action = AddRelationshipAction()
        info[.selection] = [book]
        XCTAssertTrue(checkActionValidation(action, withInfo: info) { monitor in
            let manager = monitor.actionManager
            XCTAssertFalse(manager.validate(identifier: "AddRelationship", info: info).enabled)
            info.addObserver(self)
            info[.selection] = [book]
            info[.role] = "author"

            XCTAssertTrue(manager.validate(identifier: "AddRelationship", info: info).enabled)
            monitor.allChecksDone()
        })

    }
    
    func testAddRelationship() {
        let book = Book(named: "Test")
        let info = ActionInfo()
        let action = AddRelationshipAction()
        info[.selection] = [book]
        info[.role] = "author"
        XCTAssertTrue(checkAction(action, withInfo: info) { monitor in
            // check that the change notification fired ok
            monitor.check(count: monitor.storeChanges[0].added.count, expected: 2)
            
            monitor.store.get(allEntitiesOfType: .person) { people in
                let person = people[0]
                
                // check that we have the right property
                monitor.store.get(allPropertiesOf: [book]) { results in
                    let properties = results[0]
                    let key = PropertyKey("author-\(person.identifier)")
                    let value = properties[key] as? Person
                    XCTAssertNotNil(value)
                    XCTAssertEqual(value!.identifier, person.identifier)
                    monitor.allChecksDone()
                }
            }
        })
    }

    func testRemoveRelationship() {
        let person = Person(named: "Test")
        let book = Book(named: "Test", with: PropertyDictionary.withRole("author", for: person))
        
        XCTAssertTrue(checkContainer() { monitor in
            monitor.container.store.get(entitiesWithIDs: [person, book]) { entities in
                let info = ActionInfo()
                let action = RemoveRelationshipAction()
                info[.selection] = [book]
                info[.role] = "author"
                info[.person] = person
                self.checkAction(action, withInfo: info, monitor: monitor) { monitor in
                    // check that the change notification fired ok
                    monitor.check(count: monitor.storeChanges[0].changed.count, expected: 1)

                    // check that we have the right property
                    monitor.store.get(allPropertiesOf: [book]) { results in
                        let properties = results[0]
                        let key = PropertyDictionary.keyForRole("author", for: person)
                        let value = properties[key] as? Person
                        XCTAssertNil(value)
                        monitor.allChecksDone()
                    }
                }
            }
        })
    }
//
//    func testChangeRelationshipAction() {
//        let book = Book(context: context)
//        let person = Person(context: context)
//        let relationship = person.relationship(as: Role.StandardName.author)
//        book.addToRelationships(relationship)
//        check(relationship: relationship, book: book, person: person)
//
//        let otherPerson = Person(context: context)
//        info[PersonAction.relationshipKey] = relationship
//        info[PersonAction.personKey] = otherPerson
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
//        actionManager.perform(identifier: "ChangeRelationship", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.roles.count, 1)
//        if let relationship = book.relationships?.allObjects.first as? Relationship {
//            check(relationship: relationship, book: book, person: otherPerson)
//        } else {
//            XCTFail()
//        }
//
//        XCTAssertEqual(count(of: "Person"), 2)
//        XCTAssertEqual(count(of: "Relationship"), 1) // we've made a new relationship, but removed the old one, so the count should be the same
//        XCTAssertEqual(count(of: "Book"), 1)
//    }
//
//    func testChangeRelationshipActionAdding() {
//        let book = Book(context: context)
//        let person = Person(context: context)
//        let relationship = person.relationship(as: Role.StandardName.author)
//        book.addToRelationships(relationship)
//        check(relationship: relationship, book: book, person: person)
//
//        let otherPerson = Person(context: context)
//        info[PersonAction.personKey] = otherPerson
//        info[.selection] = [book]
//        let newRole = Role.named(Role.StandardName.editor, in: context)
//        info[PersonAction.roleKey] = newRole
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
//        actionManager.perform(identifier: "ChangeRelationship", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.roles.count, 2)
//        XCTAssertTrue(book.roles.contains(Role.named(Role.StandardName.author, in: context)))
//        XCTAssertTrue(book.roles.contains(newRole))
//        XCTAssertEqual(count(of: "Person"), 2)
//        XCTAssertEqual(count(of: "Relationship"), 2)
//        XCTAssertEqual(count(of: "Book"), 1)
//    }
//
//    func testChangeRelationshipActionChangingRole() {
//        let book = Book(context: context)
//        let person = Person(context: context)
//        let relationship = person.relationship(as: Role.StandardName.author)
//        book.addToRelationships(relationship)
//        check(relationship: relationship, book: book, person: person)
//
//        let newRole = Role.named(Role.StandardName.editor, in: context)
//        info[PersonAction.relationshipKey] = relationship
//        info[PersonAction.roleKey] = newRole
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
//        actionManager.perform(identifier: "ChangeRelationship", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.roles.count, 1)
//        if let relationship = book.relationships?.allObjects.first as? Relationship {
//            check(relationship: relationship, book: book, person: person)
//            XCTAssertEqual(relationship.role, newRole)
//        } else {
//            XCTFail()
//        }
//
//        XCTAssertEqual(count(of: "Person"), 1) // shouldn't have made a new person
//        XCTAssertEqual(count(of: "Relationship"), 1) // we've made a new relationship, but removed the old one, so the count should be the same
//        XCTAssertEqual(count(of: "Book"), 1)
//    }
//
//    func testChangeRelationshipActionNewPerson() {
//        let book = Book(context: context)
//        let person = Person(context: context)
//        let relationship = person.relationship(as: Role.StandardName.author)
//        book.addToRelationships(relationship)
//        check(relationship: relationship, book: book, person: person)
//
//        info[PersonAction.relationshipKey] = relationship
//        info[PersonAction.personKey] = "New Person"
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeRelationship", info: info).enabled)
//        actionManager.perform(identifier: "ChangeRelationship", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.roles.count, 1)
//        if let relationship = book.relationships?.allObjects.first as? Relationship {
//            XCTAssertEqual(relationship.person?.name, "New Person")
//            check(relationship: relationship, book: book, person: relationship.person!)
//        } else {
//            XCTFail()
//        }
//
//        XCTAssertEqual(count(of: "Person"), 2)
//        XCTAssertEqual(count(of: "Relationship"), 1) // we've made a new relationship, but removed the old one, so the count should be the same
//        XCTAssertEqual(count(of: "Book"), 1)
//    }
//
//    func testAddPublisher() {
//        let book = Book(context: context)
//        XCTAssertNil(book.publisher)
//
//        XCTAssertFalse(actionManager.validate(identifier: "AddPublisher", info: info).enabled)
//
//        info.addObserver(self)
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "AddPublisher", info: info).enabled)
//        actionManager.perform(identifier: "AddPublisher", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertNotNil(book.publisher)
//        XCTAssertNotNil(publisherObserved)
//    }
//
//    func testRemovePublisher() {
//        let book = Book(context: context)
//        let publisher = Publisher(context: context)
//        book.publisher = publisher
//
//        XCTAssertFalse(actionManager.validate(identifier: "RemovePublisher", info: info).enabled)
//
//        info.addObserver(self)
//        info[PublisherAction.publisherKey] = publisher
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "RemovePublisher", info: info).enabled)
//        actionManager.perform(identifier: "RemovePublisher", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertNotNil(publisherObserved)
//        XCTAssertNil(book.publisher)
////        XCTAssertNil(publisher.managedObjectContext)
//    }
//
//    func testChangePublisherAction() {
//        let book = Book(context: context)
//        let publisher = Publisher(context: context)
//        book.publisher = publisher
//
//        let otherPublisher = Publisher(context: context)
//        info[PublisherAction.newPublisherKey] = otherPublisher
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangePublisher", info: info).enabled)
//        actionManager.perform(identifier: "ChangePublisher", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.publisher, otherPublisher)
//    }
//
//    func testChangePublisherActionNewPublisher() {
//        let book = Book(context: context)
//        let publisher = Publisher(context: context)
//        book.publisher = publisher
//
//        info[PublisherAction.newPublisherKey] = "New Publisher"
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangePublisher", info: info).enabled)
//        actionManager.perform(identifier: "ChangePublisher", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertEqual(book.publisher?.name, "New Publisher")
//        XCTAssertEqual(count(of: "Publisher"), 2)
//        XCTAssertEqual(count(of: "Book"), 1)
//    }
//
//    func testAddSeries() {
//        let book = Book(context: context)
//        XCTAssertEqual(book.entries.count, 0)
//
//        XCTAssertFalse(actionManager.validate(identifier: "AddSeries", info: info).enabled)
//
//        info.addObserver(self)
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "AddSeries", info: info).enabled)
//        actionManager.perform(identifier: "AddSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        let entry = book.entries.first
//        XCTAssertNotNil(entry)
//        XCTAssertNotNil(entry!.series)
//        XCTAssertEqual(entry!.position, 1)
//        XCTAssertNotNil(seriesObserved)
//    }
//
//    func testRemoveSeries() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        book.addToSeries(series, position: 1)
//
//        XCTAssertFalse(actionManager.validate(identifier: "RemoveSeries", info: info).enabled)
//
//        info.addObserver(self)
//        info[SeriesAction.seriesKey] = series
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "RemoveSeries", info: info).enabled)
//        actionManager.perform(identifier: "RemoveSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertNotNil(seriesObserved)
//        XCTAssertEqual(book.entries.count, 0)
//    }
//
//    func testChangeSeriesAction() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        series.name = "Series"
//        book.addToSeries(series, position: 2)
//
//        let otherSeries = Series(context: context)
//        otherSeries.name = "Other Series"
//
//        // parameters to change from series to otherSeries
//        info[SeriesAction.seriesKey] = series
//        info[SeriesAction.newSeriesKey] = otherSeries
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeSeries", info: info).enabled)
//        actionManager.perform(identifier: "ChangeSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        // should have removed the entry for series, and added an entry for otherSeries at position 2
//        XCTAssertTrue(check(book: book, series: otherSeries, position: 2))
//        XCTAssertEqual(book.entries.count, 1)
//    }
//
//    func testChangeSeriesActionChangePosition() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        series.name = "Series"
//        book.addToSeries(series, position: 2)
//
//        // parameters to change the position of an existing series
//        info[SeriesAction.seriesKey] = series
//        info[SeriesAction.positionKey] = 1
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeSeries", info: info).enabled)
//        actionManager.perform(identifier: "ChangeSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertTrue(check(book: book, series: series, position: 1))
//        XCTAssertEqual(book.entries.count, 1)
//    }
//
//    func testChangeSeriesActionAdding() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        series.name = "Series"
//        let entry = book.addToSeries(series, position: 1)
//
//        let otherSeries = Series(context: context)
//        otherSeries.name = "Other Series"
//
//        info[SeriesAction.newSeriesKey] = otherSeries
//        info[.selection] = [book]
//        info[SeriesAction.positionKey] = 2
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeSeries", info: info).enabled)
//        actionManager.perform(identifier: "ChangeSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertTrue(check(book: book, series: otherSeries, position: 2, ignore: entry))
//        XCTAssertEqual(count(of: "Series"), 2)
//        XCTAssertEqual(count(of: "Book"), 1)
//        XCTAssertEqual(book.entries.count, 2)
//    }
//
//    func testChangeSeriesActionNewSeriesByName() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        series.name = "Series"
//        let entry = book.addToSeries(series, position: 1)
//
//        info[SeriesAction.newSeriesKey] = "New Series"
//        info[.selection] = [book]
//        info[SeriesAction.positionKey] = 2
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeSeries", info: info).enabled)
//        actionManager.perform(identifier: "ChangeSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertTrue(check(book: book, seriesName: "New Series", position: 2, ignore: entry))
//        XCTAssertEqual(count(of: "Series"), 2)
//        XCTAssertEqual(count(of: "Book"), 1)
//        XCTAssertEqual(book.entries.count, 2)
//    }
//
//    func testChangeSeriesActionNewSeriesNoPosition() {
//        let book = Book(context: context)
//        let series = Series(context: context)
//        series.name = "Series"
//        let entry = book.addToSeries(series, position: 1)
//
//        info[SeriesAction.newSeriesKey] = "New Series"
//        info[.selection] = [book]
//
//        XCTAssertTrue(actionManager.validate(identifier: "ChangeSeries", info: info).enabled)
//        actionManager.perform(identifier: "ChangeSeries", info: info)
//
//        wait(for: [expectation], timeout: 1.0)
//
//        XCTAssertTrue(check(book: book, seriesName: "New Series", position: 0, ignore: entry))
//        XCTAssertEqual(count(of: "Series"), 2)
//        XCTAssertEqual(count(of: "Book"), 1)
//        XCTAssertEqual(book.entries.count, 2)
//    }
}
