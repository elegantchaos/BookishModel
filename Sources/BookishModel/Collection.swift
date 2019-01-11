// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

@objc open class BookishCollection: NSPersistentContainer {
    public typealias LoadedCallback = (BookishCollection, Error?) -> Void
    public init(url: URL? = nil, usingSample: Bool = false, callback: LoadedCallback? = nil) {
        let model = BookishModel.model()
        super.init(name: "Default", managedObjectModel: model)
        let description = persistentStoreDescriptions[0]
        description.setOption(true as NSValue, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSValue, forKey: NSInferMappingModelAutomaticallyOption)

        if let explicitURL = url {
            description.url = explicitURL
        }

        loadPersistentStores { (description, error) in
            if error == nil {
                let context = self.viewContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                
                if usingSample {
                    let request: NSFetchRequest<Book> = Book.fetcher(in: context)
                    if let results = try? context.fetch(request) {
                        if results.count == 0 {
                            BookishCollection.setupTestDocument(context: context)
                        }
                    }
                }
                
            callback?(self, error)
            }
        }
//        let url = persistentStoreDescriptions[0].url
//        let description = NSPersistentStoreDescription(url: url!)
//        description.options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//        .options[NSMigratePersistentStoresAutomaticallyOption] = true
    }
    
    public var managedObjectContext: NSManagedObjectContext { return viewContext }
    
//    public func configure(for url: URL) {
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: BookishModel.model())
//        let options =
//        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//    }
    
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
