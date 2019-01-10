// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

@objc open class BookishCollection: NSObject {
    public let managedObjectContext: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)) {
        managedObjectContext = context
        super.init()
    }
    
    public func configure(for url: URL) {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: BookishModel.model())
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func setupTestDocument() {
        BookishCollection.setupTestDocument(context: managedObjectContext)
    }
    
    /**
     Populate the document with some test data.
     */
    
    public class func setupTestDocument(context: NSManagedObjectContext) {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        
//        let desc = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName["Person"]!
//        let sharedEditor = NSManagedObject(entity: desc!, insertInto: context) as! Person
        let sharedEditor = Person(context: context)
        sharedEditor.name = "Ms Editor"
        sharedEditor.notes = "This person is the editor of a number of books."
        let entry = sharedEditor.relationship(as: Role.Default.editorName)
        
        let book = Book(context: context)
        book.name = "A Book"
        book.notes = "Some\nmulti\nline\nnotes."
        entry.addToBooks(book)

        let publisher = Publisher(context: context)
        publisher.notes = "Some notes about the publisher"
        publisher.addToBooks(book)

        sharedEditor.relationship(as: Role.Default.authorName).addToBooks(book)
        sharedEditor.relationship(as: Role.Default.illustratorName).addToBooks(book)

        let sharedPublisher = Publisher(context: context)
        sharedPublisher.name = "Publisher 2"
        sharedPublisher.notes = "Some notes about the publisher"

        let series = Series(context: context)
        series.name = "Example Series"
        series.notes = "Some notes about the series"

        
        for n in 1...3 {
            let book = Book(context: context)
            book.name = "Book \(n)"
            book.subtitle = "Slightly longer subtitle \(n)"
            book.notes = "This is an example book."
            book.published = formatter.date(from: "12/11/69")
            entry.addToBooks(book)
            let illustrator = Person(context: context)
            illustrator.name = "Mr Illustrator \(n)"
            illustrator.notes = "Another example person."
            let entry2 = illustrator.relationship(as: Role.Default.illustratorName)
            entry2.addToBooks(book)
            
            sharedPublisher.addToBooks(book)
            
            let entry = Entry(context: context)
            entry.book = book
            entry.index = Int16(n)
            series.addToEntries(entry)
        }
    }
    
}
