// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

@objc open class CollectionContainer: NSPersistentContainer {
    public enum PopulateMode {
        case empty                  /// don't populate with anything
        case defaultRoles           /// add default roles only
        case testData               /// add default roles and test data if empty
        case sampleData             /// add previously saved sample data if empty
        case replaceWithTestData    /// wipe existing data and add test data
        case replaceWithSampleData  /// wipe existing data and add sample data
    }
    
    public typealias LoadedCallback = (CollectionContainer, Error?) -> Void
    
    public init(name: String, url: URL? = nil, mode: PopulateMode = .defaultRoles, callback: LoadedCallback? = nil) {
        let fm = FileManager.default
        let model = BookishModel.model()
        super.init(name: name, managedObjectModel: model)
        viewContext.undoManager = UndoManager()
        let description = persistentStoreDescriptions[0]
        description.setOption(true as NSValue, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSValue, forKey: NSInferMappingModelAutomaticallyOption)

        if let explicitURL = url {
            description.url = explicitURL
        }

        if let url = description.url {
            
            if fm.fileExists(at: url) && ((mode == .replaceWithTestData) || (mode == .replaceWithSampleData)) {
                deleteStores()
            }
            
            if !fm.fileExists(atPath: url.path) && ((mode == .sampleData) || (mode == .replaceWithSampleData)) {
                if let sample = Bundle.main.url(forResource: "Sample", withExtension: "sqlite") {
                    do {
                        try fm.copyItem(at: sample, to: url)
                    } catch {
                        print("failed to copy sample database")
                    }
                }
            }
        }
        
        load(mode: mode, callback: callback)
    }
    
    
    open func reset(callback: LoadedCallback? = nil) {
        managedObjectContext.reset()
        managedObjectContext.processPendingChanges()
        deleteStores(remove: false)
        load(mode: .empty, callback: callback)
    }

    open func delete(remove: Bool = false) {
        managedObjectContext.reset()
        managedObjectContext.processPendingChanges()
        deleteStores(remove: remove)
    }

    func load(mode: PopulateMode = .empty, callback: LoadedCallback? = nil) {
        loadPersistentStores { (description, error) in
            if error == nil {
                let context = self.viewContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

                if (mode == .testData) || (mode == .replaceWithTestData) {
                    let request: NSFetchRequest<Book> = Book.fetcher(in: context)
                    if let results = try? context.fetch(request) {
                        if results.count == 0 {
                            self.setupTestData()
                        }
                    }
                } else if (mode == .defaultRoles) {
                    let request: NSFetchRequest<Role> = Role.fetcher(in: context)
                    if let results = try? context.fetch(request) {
                        if results.count == 0 {
                            self.makeDefaultRoles(context: context)
                        }
                    }
                }
                
                callback?(self, error)
            }
        }
    }
    
    public func save() {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func deleteStores(remove: Bool = false) {
        let fm = FileManager.default
        if let coordinator = managedObjectContext.persistentStoreCoordinator {
            for store in coordinator.persistentStores {
                if let url: URL = store.url {
                    do {
                        try coordinator.destroyPersistentStore(at: url, ofType: store.type, options: nil)
                        if remove && fm.fileExists(atPath: url.path) {
                            try? fm.removeItem(at: url)
                        }
                    } catch {
                        print("failed to delete previous database")
                    }
                }
                try? coordinator.remove(store)
            }
        }
    }
    
    public var managedObjectContext: NSManagedObjectContext { return viewContext }
    
    /**
     A few roles should always be present.
     */
    
    func makeDefaultRoles(context: NSManagedObjectContext) {
        for role in Role.StandardNames.names {
            _ = Role.named(role, in: context)
        }
    }

    
    /**
     Populate the document with some test data.
     */

    func setupTestData() {
        let context = viewContext
        
        makeDefaultRoles(context: context)
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        
        let sharedEditor = Person(context: context)
        sharedEditor.name = "Ms Editor"
        sharedEditor.uuid = "person-1"
        sharedEditor.notes = "This person is the editor of a number of books."
        let entry = sharedEditor.relationship(as: Role.StandardNames.editor)
        
        let book = Book(context: context)
        book.name = "A Book"
        book.uuid = "book-1"
        book.notes = "Some\nmulti\nline\nnotes."
        entry.addToBooks(book)
        
        let publisher = Publisher(context: context)
        publisher.notes = "Some notes about the publisher"
        publisher.uuid = "publisher-1"
        publisher.addToBooks(book)
        
        sharedEditor.relationship(as: Role.StandardNames.author).addToBooks(book)
        sharedEditor.relationship(as: Role.StandardNames.illustrator).addToBooks(book)
        
        let sharedPublisher = Publisher(context: context)
        sharedPublisher.name = "Publisher 2"
        sharedPublisher.notes = "Some notes about the publisher"
        
        let series = Series(context: context)
        series.name = "Example Series"
        series.uuid = "series-1"
        series.notes = "Some notes about the series"
        
        for n in 2...4 {
            let book = Book(context: context)
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
            let entry2 = illustrator.relationship(as: Role.StandardNames.illustrator)
            entry2.addToBooks(book)
            
            sharedPublisher.addToBooks(book)
            
            let entry = SeriesEntry(context: context)
            entry.book = book
            entry.position = Int16(n)
            series.addToEntries(entry)
        }
        
        save()
    }
    
    
}
