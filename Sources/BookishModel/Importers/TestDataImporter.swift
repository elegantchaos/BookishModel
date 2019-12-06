// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore

public class TestDataImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.test-data" }

    public init(manager: ImportManager) {
        super.init(name: "Test Data", source: .knownLocation, manager: manager)
    }

    override func makeSession(in store: Datastore, monitor: ImportDelegate?) -> ImportSession? {
        return TestDataImportSession(importer: self, store: store, monitor: monitor)
    }

}

class TestDataImportSession: StandardRolesImportSession {
    /**
     Populate the document with some test data.
     */
    
    func setupTestData() {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        
        let monitor = self.monitor
        let count = 4
        monitor?.importerWillStartSession(self, withCount: count)

        var entities: [EntityReference] = []
        var item = 0

        let tag = Entity.named("test", createAs: .tag)

        let editorRole = Entity.identifiedBy(Role.StandardName.editor.identifier)
        let sharedEditor = Entity.identifiedBy("person-1", createAs: .person, with: [
            .name: "Ms Editor",
            .notes: "This person is the editor of a number of books."
        ])
        

        let book = Entity.identifiedBy("book-1", createAs: .book, with: [
            .name: "A Book",
            .notes: "Some\nmulti\nline\nnotes.",
            PropertyKey("editor-1"): (sharedEditor, PropertyType.editor),
            PropertyKey("tag-1"): tag
        ])
        
//
//        let tag = Tag.named("test", in: context)
//        tag.addToBooks(book)
//        
//        let publisher = Publisher(context: context)
//        publisher.notes = "Some notes about the publisher"
//        publisher.uuid = "publisher-1"
//        publisher.add(book)
//        
//        sharedEditor.relationship(as: Role.StandardName.author).add(book)
//        sharedEditor.relationship(as: Role.StandardName.illustrator).add(book)
//        
//        let sharedPublisher = Publisher(context: context)
//        sharedPublisher.name = "Publisher 2"
//        sharedPublisher.notes = "Some notes about the publisher"
//        
//        let series = Series(context: context)
//        series.name = "Example Series"
//        series.uuid = "series-1"
//        series.notes = "Some notes about the series"
//        
//        for n in 2...4 {
//            let book = Book(context: context)
//            tag.addToBooks(book)
//            book.name = "Book \(n)"
//            book.uuid = "book-\(n)"
//            book.subtitle = "Slightly longer subtitle \(n)"
//            book.notes = "This is an example book."
//            book.published = formatter.date(from: "12/11/69")
//            entry.add(book)
//            let illustrator = Person(context: context)
//            illustrator.name = "Mr Illustrator \(n)"
//            illustrator.uuid = "person-\(n)"
//            illustrator.notes = "Another example person."
//            let entry2 = illustrator.relationship(as: Role.StandardName.illustrator)
//            entry2.add(book)
//            
//            sharedPublisher.add(book)
//            
//            let entry = SeriesEntry(context: context)
//            entry.book = book
//            entry.position = Int16(n)
//            series.addToEntries(entry)
//        }
    }
    
    
    override func run() {
        super.run()
        setupTestData()
    }
}
