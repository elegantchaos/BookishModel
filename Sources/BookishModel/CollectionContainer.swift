// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Datastore
import Logger

let collectionChannel = Channel("com.elegantchaos.bookish.model.collection")

open class CollectionContainer {
    let store: Datastore
    
    public enum PopulateMode {
        case empty                              /// don't populate with anything
        case populateWith(sample: String)       /// if empty, add some sample data
        case replaceWith(sample: String)        /// wipe existing data and replace with some sample data
    }
    
    public typealias LoadResult = Result<CollectionContainer, Error>
    public typealias LoadCompletion = (LoadResult) -> Void
    
    public class func load(name: String, url: URL? = nil, mode: PopulateMode = .empty, indexed: Bool = true, completion: @escaping LoadCompletion) {
        let fm = FileManager.default
        let bundle = Bundle.init(for: CollectionContainer.self)
        if let url = url {
            switch mode {
                case let .replaceWith(sampleName):
                    if let sampleURL = bundle.url(forResource: sampleName, withExtension: "sqlite", subdirectory: sampleName) {
                        Datastore.replace(storeAt: url, withStoreAt: sampleURL)
                }
                
                case let .populateWith(sample: sampleName):
                    if !fm.fileExists(atPath: url.path), let sampleURL = bundle.url(forResource: sampleName, withExtension: "sqlite", subdirectory: sampleName) {
                        Datastore.replace(storeAt: url, withStoreAt: sampleURL)
                }
                
                default:
                    break
            }
        }
        
        Datastore.load(name: name, url: url, indexed: true) { result in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                
                case .success(let store):
                    let container = CollectionContainer(store: store)
                    container.printSummary()
                    completion(.success(container))
            }
        }
    }

    init(store: Datastore) {
        self.store = store
    }
    
//    open func reset(callback: LoadedCallback? = nil) {
//        managedObjectContext.reset()
//        managedObjectContext.processPendingChanges()
//        deleteStores(remove: false)
//        load(callback: callback)
//    }
//    
//    open func delete(remove: Bool = false) {
//        managedObjectContext.reset()
//        managedObjectContext.processPendingChanges()
//        deleteStores(remove: remove)
//    }
    
    func printSummary() {
        store.count(entitiesOfTypes: [.book, .person, .series, .publisher]) { counts in
            print("Loaded \(counts[0]) books, in \(counts[2]) series, \(counts[3]) publishers, \(counts[1]) people.")
        }
    }
    
    public func save() {
        store.save() { result in
            // TODO: report error?
            switch result {
                case .success:
                    break
                
                case .failure(let error):
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
