// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

@objc open class CollectionContainer: NSPersistentContainer {
    public typealias LoadedCallback = (CollectionContainer, Error?) -> Void
    
    public init(url: URL? = nil, usingSample: Bool = false, addTestData: Bool = false, callback: LoadedCallback? = nil) {
        let fm = FileManager.default
        let model = BookishModel.model()
        super.init(name: "Default", managedObjectModel: model)
        let description = persistentStoreDescriptions[0]
        description.setOption(true as NSValue, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSValue, forKey: NSInferMappingModelAutomaticallyOption)

        if let explicitURL = url {
            description.url = explicitURL
        }

        if let url = description.url {
            if !fm.fileExists(atPath: url.path) && usingSample {
                if let sample = Bundle.main.url(forResource: "Sample", withExtension: "sqlite") {
                    do {
                        try fm.copyItem(at: sample, to: url)
                    } catch {
                        print("failed to copy sample database")
                    }
                }
            }
        }
        
        loadPersistentStores { (description, error) in
            if error == nil {
                let context = self.viewContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                
                if addTestData {
                    let request: NSFetchRequest<Book> = Book.fetcher(in: context)
                    if let results = try? context.fetch(request) {
                        if results.count == 0 {
                            self.setupTestData()
                        }
                    }
                }
                
            callback?(self, error)
            }
        }
    }
    
    public var managedObjectContext: NSManagedObjectContext { return viewContext }
    
    /**
     Populate the document with some test data.
     */

    func setupTestData() {
        let context = viewContext
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        
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
