// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger

let collectionChannel = Channel("com.elegantchaos.bookish.model.collection")

@objc open class CollectionContainer: NSPersistentContainer {
    public enum PopulateMode {
        case empty                              /// don't populate with anything
        case populateWith(sample: String)       /// if empty, add some sample data
        case replaceWith(sample: String)        /// wipe existing data and replace with some sample data
    }
    
    public typealias LoadedCallback = (CollectionContainer, Error?) -> Void
    
    public init(name: String, url: URL? = nil, mode: PopulateMode = .empty, callback: LoadedCallback? = nil) {
        let fm = FileManager.default
        let model = BookishModel.model()
        let bundle = Bundle.init(for: CollectionContainer.self)
        super.init(name: name, managedObjectModel: model)
        let description = persistentStoreDescriptions[0]
        description.setOption(true as NSValue, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSValue, forKey: NSInferMappingModelAutomaticallyOption)
        description.type = NSSQLiteStoreType
        
        if let explicitURL = url {
            description.url = explicitURL
        }

        if let url = description.url {
            
            if fm.fileExists(at: url) {
                switch mode {
                case let .replaceWith(sampleName):
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                if let sampleURL = bundle.url(forResource: sampleName, withExtension: "sqlite") {
                    do {
                        try coordinator.replacePersistentStore(at: url, destinationOptions: [:], withPersistentStoreFrom: sampleURL, sourceOptions: [:], ofType: NSSQLiteStoreType)
                    } catch {
                        collectionChannel.log("Failed to replace collection with sample \(sampleName).\n\n\(error)")
                    }
                }
                    
                default:
                    break
                }
            }

            if !fm.fileExists(atPath: url.path) {
                switch mode {
                case let .replaceWith(sample: sampleName), let .populateWith(sample: sampleName):
                    if let sample = bundle.url(forResource: sampleName, withExtension: "sqlite") {
                        do {
                            try? fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                            try fm.copyItem(at: sample, to: url) // TODO: do we need to copy the -shm and -wal files too?
                        } catch {
                            collectionChannel.log("Failed to populate collection with sample \(sampleName).\n\n\(error)")
                        }
                    }

                default:
                    break
                }
            }
        }
        
        load(callback: callback)
    }
    
    
    open func reset(callback: LoadedCallback? = nil) {
        managedObjectContext.reset()
        managedObjectContext.processPendingChanges()
        deleteStores(remove: false)
        load(callback: callback)
    }

    open func delete(remove: Bool = false) {
        managedObjectContext.reset()
        managedObjectContext.processPendingChanges()
        deleteStores(remove: remove)
    }

    func load(callback: LoadedCallback? = nil) {
        loadPersistentStores { (description, error) in
            if let error = error {
                print(error)
            } else {
                let context = self.viewContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = UndoManager()
                self.printSummary()
                callback?(self, error)
            }
        }
    }
    
    func printSummary() {
        let context = viewContext
        let bookCount = context.countEntities(type: Book.self)
        let seriesCount = context.countEntities(type: Series.self)
        print("Loaded \(bookCount) books, in \(seriesCount) series.")
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
    
    
    func deleteStores(remove: Bool = false, url: URL? = nil) {
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
        } else if let url = url, fm.fileExists(atPath: url.path) {
            try? fm.removeItem(at: url)
        }
    }
    
    public var managedObjectContext: NSManagedObjectContext { return viewContext }    
    
}
