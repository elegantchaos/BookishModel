// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

@testable import BookishModel
import XCTest
import CoreData
import Actions

class BookishModelActionTests: ModelTestCase, BookViewer, PersonViewer {
    
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!
    var actionManager: ActionManager!
    var info: ActionInfo = ActionInfo()
    var expectation: XCTestExpectation!
    var bookRevealed: Book?
    var personRevealed: Person?

    func reveal(book: Book) {
        bookRevealed = book
    }
    
    func reveal(person: Person) {
        personRevealed = person
    }

    override func setUp() {
        container = makeTestContainer()
        context = container.viewContext
        actionManager = ActionManager()
        actionManager.register(PersonAction.standardActions())
        actionManager.register(BookAction.standardActions())
        
        info[ActionContext.modelKey] = context
        info.registerNotification { (stage, context) in
            if stage == .didPerform {
                self.expectation.fulfill()
            }
        }
        expectation = XCTestExpectation(description: "action done")
    }
    
    func count(of type: String, in context: NSManagedObjectContext? = nil) -> Int {
        let requestContext = context != nil ? context! : (self.context as NSManagedObjectContext)
        var count = NSNotFound
        requestContext.performAndWait {
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: type)
            if let result = try? requestContext.fetch(request) {
                count = result.count
            }
        }
        return count
    }
    
    func created(person: Person) {
        expectation.fulfill()
    }
    
    func testNewPerson() {
        actionManager.perform(identifier: "NewPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 1)
    }
    
    func testDeletePeople() {
        let person = Person(context: context)
        XCTAssertEqual(count(of: "Person"), 1)

        info[ActionContext.selectionKey] = [person]

        actionManager.perform(identifier: "DeletePeople", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Person"), 0)
    }
    
    func testRevealPerson() {
        let person = Person(context: context)
        info[ActionContext.rootKey] = self
        info[PersonAction.personKey] = person
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personRevealed, person)
    }

    func testRevealPersonFromRelationship() {
        let person = Person(context: context)
        let relationship = person.relationship(as: "Author")
        info[ActionContext.rootKey] = self
        info[PersonAction.relationshipKey] = relationship
        actionManager.perform(identifier: "RevealPerson", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(personRevealed, person)
    }

    func testAddRelationship() {
        let book = Book(context: context)
        XCTAssertEqual(book.roles.count, 0)
        info[ActionContext.selectionKey] = [book]
        info[PersonAction.roleKey] = "author"
        actionManager.perform(identifier: "AddRelationship", info: info)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(book.roles.first?.name, "author")
    }
    
    func testRemoveRelationship() {
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        XCTAssertEqual(book.roles.count, 1)

        info[PersonAction.relationshipKey] = relationship
        info[ActionContext.selectionKey] = [book]
        actionManager.perform(identifier: "RemoveRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(book.roles.count, 0)
    }
    
    func testChangeRelationshipAction() {
        func check(relationship: Relationship, book: Book, person: Person) {
            XCTAssertEqual(book.roles.count, 1)
            XCTAssertEqual(relationship.books?.count, 1)
            XCTAssertEqual(relationship.books?.allObjects.first as? Book, book)
            XCTAssertEqual(relationship.person, person)
        }
        
        let book = Book(context: context)
        let person = Person(context: context)
        let relationship = person.relationship(as: Role.Default.authorName)
        book.addToRelationships(relationship)
        check(relationship: relationship, book: book, person: person)

        let otherPerson = Person(context: context)
        info[PersonAction.relationshipKey] = relationship
        info[PersonAction.personKey] = otherPerson
        info[ActionContext.selectionKey] = [book]
        actionManager.perform(identifier: "ChangeRelationship", info: info)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(book.roles.count, 1)
        if let relationship = book.relationships?.allObjects.first as? Relationship {
            check(relationship: relationship, book: book, person: otherPerson)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(count(of: "Person"), 2)
        XCTAssertEqual(count(of: "Relationship"), 2)
        XCTAssertEqual(count(of: "Book"), 1)
    }
    
    func testNewBook() {
        actionManager.perform(identifier: "NewBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 1)
    }
    
    func testDeleteBooks() {
        let book = Book(context: context)
        XCTAssertEqual(count(of: "Book"), 1)
        
        info[ActionContext.selectionKey] = [book]
        
        actionManager.perform(identifier: "DeleteBooks", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(count(of: "Book"), 0)
    }
    
    func testRevealBook() {
        let book = Book(context: context)
        info[ActionContext.rootKey] = self
        info[BookAction.bookKey] = book
        actionManager.perform(identifier: "RevealBook", info: info)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRevealed, book)
    }
}
