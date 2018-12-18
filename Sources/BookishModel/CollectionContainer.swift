// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class CollectionContainer: NSPersistentContainer {
    
    public class func makeDefaultContainer(name: String) -> CollectionContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = CollectionContainer(name: name)
        container.load()
        return container
    }
    
    public override class func defaultDirectoryURL() -> URL {
        return super.defaultDirectoryURL().appendingPathComponent("BookishModel")
    }
    
    public init(name: String) {
        super.init(name: name, managedObjectModel: BookishModel.loadModel())
    }
    
    public func load(usingSample: Bool = false, reset: Bool = false) {
        var madeNewCollection = false
        if let description = persistentStoreDescriptions.first, let url = description.url {
            let fm = FileManager.default
            if reset {
                do {
                    try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: description.type, options: nil)
                    if usingSample {
                        try fm.removeItem(at: url)
                    }
                    madeNewCollection = true
                } catch {
                    print("failed to delete previous database")
                }
            }
            
            if !fm.fileExists(atPath: url.path) || madeNewCollection {
                madeNewCollection = true
                if usingSample, let sample = Bundle.main.url(forResource: "Sample", withExtension: "sqlite") {
                    do {
                        try fm.copyItem(at: sample, to: url)
                    } catch {
                        print("failed to copy sample database")
                    }
                }
            }
        }
        
        loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        if madeNewCollection && !usingSample {
            Collection.setupTestDocument(context: viewContext)
            save()
        }
        
    }
    
    public func delete() {
        viewContext.reset()
        viewContext.processPendingChanges()
        if let description = persistentStoreDescriptions.first, let url = description.url {
            let fm = FileManager.default
            if fm.fileExists(atPath: url.path) {
                try? fm.removeItem(at: url)
            }
        }
    }
    
    public func reset() {
        if let description = persistentStoreDescriptions.first, let url = description.url {
            let fm = FileManager.default
            if fm.fileExists(atPath: url.path) {
                try? fm.removeItem(at: url)
            }

            viewContext.reset()
            loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })

            Collection.setupTestDocument(context: viewContext)
        }
    }
        
    public func save() {
        let context = viewContext
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
}
