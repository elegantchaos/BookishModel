// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
@testable import BookishModel
import Actions


//class BookActionTests: ModelActionTestCase, BookViewer, BookLifecycleObserver, BookChangeObserver {
//    var bookObserved: Book?
//    var relationshipObserved: Relationship?
//    var publisherObserved: Publisher?
//    var seriesObserved: Series?
//
//    func added(series: Series, position: Int) {
//        seriesObserved = series
//    }
//    
//    func removed(series: Series) {
//        seriesObserved = series
//    }
//    
//    func added(publisher: Publisher) {
//        publisherObserved = publisher
//    }
//    
//    func removed(publisher: Publisher) {
//        publisherObserved = publisher
//    }
//    
//    func removed(relationship: Relationship) {
//        relationshipObserved = relationship
//    }
//    
//    func added(relationship: Relationship) {
//        relationshipObserved = relationship
//    }
//
//    func reveal(book: Book, dismissPopovers: Bool) {
//        bookObserved = book
//    }
//    
//    func created(books: [Book]) {
//        bookObserved = books.first
//    }
//
//    func deleted(books: [Book]) {
//        bookObserved = books.first
//    }
//    
//    func testNewBook() {
//        info.addObserver(self)
//        XCTAssertTrue(actionManager.validate(identifier: "NewBook", info: info).enabled)
//        actionManager.perform(identifier: "NewBook", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Book"), 1)
//        XCTAssertNotNil(bookObserved)
//    }
//    
//    func testDeleteBook() {
//        let book = Book(context: context)
//        XCTAssertEqual(count(of: "Book"), 1)
//        
//        info[ActionContext.selectionKey] = [book]
//        info.addObserver(self)
//
//        XCTAssertTrue(actionManager.validate(identifier: "DeleteBook", info: info).enabled)
//
//        actionManager.perform(identifier: "DeleteBook", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(count(of: "Book"), 0)
//        XCTAssertEqual(bookObserved, book)
//
//        info[ActionContext.selectionKey] = []
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteBook", info: info).enabled)
//        
//        XCTAssertFalse(actionManager.validate(identifier: "DeleteBook", info: ActionInfo()).enabled)
//    }
//    
//    
//    func testAddRelationship() {
//        let book = Book(context: context)
//        XCTAssertEqual(book.roles.count, 0)
//
//        XCTAssertFalse(actionManager.validate(identifier: "AddRelationship", info: info).enabled)
//
//        info.addObserver(self)
//        info[ActionContext.selectionKey] = [book]
//        info[PersonAction.roleKey] = "author"
//
//        XCTAssertTrue(actionManager.validate(identifier: "AddRelationship", info: info).enabled)
//        actionManager.perform(identifier: "AddRelationship", info: info)
//        
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(book.roles.count, 1)
//        XCTAssertEqual(book.roles.first?.name, "author")
//
//        XCTAssertNotNil(relationshipObserved)
//    }
//    
//    func testRemoveRelationship() {
//        let book = Book(context: context)
//        let person = Person(context: context)
//        let relationship = person.relationship(as: Role.StandardName.author)
//        book.addToRelationships(relationship)
//        XCTAssertEqual(book.roles.count, 1)
//        
//        XCTAssertFalse(actionManager.validate(identifier: "RemoveRelationship", info: info).enabled)
//
//        info.addObserver(self)
//        info[PersonAction.relationshipKey] = relationship
//        info[ActionContext.selectionKey] = [book]
//
//        XCTAssertNotNil(relationship.managedObjectContext)
//
//        XCTAssertTrue(actionManager.validate(identifier: "RemoveRelationship", info: info).enabled)
//        actionManager.perform(identifier: "RemoveRelationship", info: info)
//        
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(book.roles.count, 0)
//        
//        XCTAssertNil(relationship.managedObjectContext)
//    }
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//        info[ActionContext.selectionKey] = [book]
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
//
//    func testRevealBook() {
//        let book = Book(context: context)
//        info[ActionContext.rootKey] = self
//        info[BookAction.bookKey] = book
//        XCTAssertTrue(actionManager.validate(identifier: "RevealBook", info: info).enabled)
//
//        actionManager.perform(identifier: "RevealBook", info: info)
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(bookObserved, book)
//    }
//}
