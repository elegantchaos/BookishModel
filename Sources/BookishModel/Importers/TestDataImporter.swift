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

    override func makeSession(in collection: CollectionContainer, monitor: ImportDelegate?) -> ImportSession? {
        return TestDataImportSession(importer: self, collection: collection, monitor: monitor)
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

        monitor?.importerWillContinueSession(self, withItem: 0, of: count)

        let tag = collection.tag(named: "test")

        let editorRole = collection.tag(identifiedBy: Role.StandardName.editor.identifier)
        let sharedEditor = collection.person(identifiedBy: "person-1", with: [
            .name: "Ms Editor",
            .notes: "This person is the editor of a number of books."
        ])
        
        let publisher = collection.publisher(identifiedBy: "publisher-1", with: [
            .name: "Example Publisher",
            .notes: "Some notes about the publisher"
            ])

        let book = collection.book(identifiedBy: "book-1", with: [
            .name: "A Book",
            .notes: "Some\nmulti\nline\nnotes.",
            .publisher: publisher,
            PropertyKey("editor-1"): (sharedEditor, PropertyType.role),
            PropertyKey("author-1"): (sharedEditor, PropertyType.role),
            PropertyKey("illustrator-1"): (sharedEditor, PropertyType.role),
            PropertyKey("tag-1"): tag
        ])

        let sharedPublisher = collection.publisher(identifiedBy: "publisher-2", with: [
            .name: "Another Publisher",
            .notes: "This publisher has multiple books"
            ])

        var seriesProperties: PropertyDictionary = [
            .name: "Example Series",
            .notes: "Some notes about the series",
            "entry-1": book
        ]

        var books: [Book] = [book]
        for n in 2...count {
            monitor?.importerWillContinueSession(self, withItem: n - 1, of: count)
            let illustrator = collection.person(identifiedBy: "person-\(n)", with:[
                .name: "Mr Illustrator \(n)",
                .notes: "Another example person."
            ])

            let book = collection.book(identifiedBy: "book-\(n)", with: [
                .name: "Book \(n)",
                .subtitle: "Slightly longer subtitle \(n)",
                .notes: "This is an example book.",
                .published: formatter.date(from: "12/11/69")!,
                .publisher: publisher,
                "editor-1": (sharedEditor, PropertyType.role),
                "illustrator-1": (illustrator, PropertyType.role)
            ])
            books.append(book)
            seriesProperties[PropertyKey("entry-\(n)")] = book
        }
        
        let series = collection.series(identifiedBy: "series-1", with: seriesProperties)

        var entities: [ModelObject] = [
            publisher,
            series,
            sharedEditor,
            sharedPublisher,
        ]
        
        entities.append(contentsOf: books)
        collection.store.get(entitiesWithIDs: entities) { result in
            print(result)
            monitor?.importerDidFinishWithStatus(.succeeded(self))
        }
    }
    
    
    override func run() {
        super.run()
        setupTestData()
    }
}
