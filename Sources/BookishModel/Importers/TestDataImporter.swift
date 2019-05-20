// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

public class TestDataImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.test-data" }

    public init(manager: ImportManager) {
        super.init(name: "Test Data", source: .knownLocation, manager: manager)
    }

    override func makeSession(in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) -> ImportSession {
        return TestDataImportSession(importer: self, context: context, completion: completion)
    }

}

class TestDataImportSession: StandardRolesImportSession {
    /**
     Populate the document with some test data.
     */
    
    func setupTestData() {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        
        let sharedEditor = Person(context: context)
        sharedEditor.name = "Ms Editor"
        sharedEditor.uuid = "person-1"
        sharedEditor.notes = "This person is the editor of a number of books."
        let entry = sharedEditor.relationship(as: Role.StandardName.editor)
        
        let book = Book(context: context)
        book.name = "A Book"
        book.uuid = "book-1"
        book.notes = "Some\nmulti\nline\nnotes."
        entry.addToBooks(book)
        
        let tag = Tag.named("test", in: context)
        tag.addToBooks(book)
        
        let publisher = Publisher(context: context)
        publisher.notes = "Some notes about the publisher"
        publisher.uuid = "publisher-1"
        publisher.addToBooks(book)
        
        sharedEditor.relationship(as: Role.StandardName.author).addToBooks(book)
        sharedEditor.relationship(as: Role.StandardName.illustrator).addToBooks(book)
        
        let sharedPublisher = Publisher(context: context)
        sharedPublisher.name = "Publisher 2"
        sharedPublisher.notes = "Some notes about the publisher"
        
        let series = Series(context: context)
        series.name = "Example Series"
        series.uuid = "series-1"
        series.notes = "Some notes about the series"
        
        for n in 2...4 {
            let book = Book(context: context)
            tag.addToBooks(book)
            book.name = "Book \(n)"
            book.uuid = "book-\(n)"
            book.subtitle = "Slightly longer subtitle \(n)"
            book.notes = "This is an example book."
            book.published = formatter.date(from: "12/11/69")
            entry.addToBooks(book)
            let illustrator = Person(context: context)
            illustrator.name = "Mr Illustrator \(n)"
            illustrator.uuid = "person-\(n)"
            illustrator.notes = "Another example person."
            let entry2 = illustrator.relationship(as: Role.StandardName.illustrator)
            entry2.addToBooks(book)
            
            sharedPublisher.addToBooks(book)
            
            let entry = SeriesEntry(context: context)
            entry.book = book
            entry.position = Int16(n)
            series.addToEntries(entry)
        }
    }
    
    
    override func run() {
        super.run()
        setupTestData()
    }
}
