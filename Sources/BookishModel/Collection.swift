// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Ensembles

@objc public class Collection: NSObject, CDEPersistentStoreEnsembleDelegate {
    /**
     Populate the document with some test data.
     */
    
    public class func setupTestDocument(context: NSManagedObjectContext) {
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
    
    var managedObjectContext: NSManagedObjectContext
    var cloudFileSystem: CDECloudKitFileSystem
    var ensemble: CDEPersistentStoreEnsemble!
    
    init(context: NSManagedObjectContext, storeURL: URL) {
        managedObjectContext = context
        
        // Setup Ensemble
        let modelURL = BookishModel.modelURL()
        cloudFileSystem = CDECloudKitFileSystem(privateDatabaseForUbiquityContainerIdentifier: "blah", schemaVersion: .version2)
        ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "NumberStore", persistentStore: storeURL, managedObjectModelURL: modelURL, cloudFileSystem: cloudFileSystem)
        super.init()

        ensemble.delegate = self

    }
    
    func sync(_ completion: (() -> Void)?) {
//        let viewController = self.window?.rootViewController as! ViewController
//        viewController.activityIndicator?.startAnimating()
        if !ensemble.isLeeched {
            ensemble.leechPersistentStore {
                error in
//                viewController.activityIndicator?.stopAnimating()
//                viewController.refresh()
                if error == nil {
                    self.sync(completion) // Trigger first merge
                }
                else {
                    completion?()
                }
            }
        }
        else {
            ensemble.merge {
                error in
//                viewController.activityIndicator?.stopAnimating()
//                viewController.refresh()
                completion?()
            }
        }
    }
    
    private func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble, didSaveMergeChangesWith notification: Notification) {
        managedObjectContext.performAndWait {
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble, globalIdentifiersFor objects: [NSManagedObject]) -> [NSObject] {
        let numberHolders = objects as! [UniqueModelObject]
        return numberHolders.map { $0.uniqueIdentifier }
    }

}
