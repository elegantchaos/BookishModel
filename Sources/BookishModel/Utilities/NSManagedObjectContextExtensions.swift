// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

extension NSManagedObjectContext {
    
    
    /**
     Return an NSFetchRequest for a given model object class.
     
     Xcode generates a `fetchRequest` method which does pretty much the same thing,
     but it uses +entity to find the entity description.
     
     This version takes in the context and uses that to look up the description in the model.
     */
    
    public func fetcher<T>() -> NSFetchRequest<T> where T: NSManagedObject {
        let request = NSFetchRequest<T>()
        request.entity = entityDescription(for: T.self)
        return request
    }
    
    /**
     Return the entity description for a given model class, using the mode from the supplied context to find it.
     */
    
    public func entityDescription<T>(for type: T) -> NSEntityDescription {
        let name = String(describing: type)
        guard let coordinator = persistentStoreCoordinator else {
            fatalError("missing coordinator")
        }
        
        guard let description = coordinator.managedObjectModel.entitiesByName[name] else {
            fatalError("no entity named \(name)")
        }
        
        return description
    }
    
    /**
     Return count of instances of a given entity type.
     */
    
    public func countEntities<Entity: NSManagedObject>(type: Entity.Type, sorting: [NSSortDescriptor]? = nil) -> Int {
        let request: NSFetchRequest<Entity> = fetcher()
        request.sortDescriptors = sorting
        return countAssertNoThrow(request)
    }

    
    /**
     Return every instance of a given entity type.
    */
    
    public func everyEntity<Entity: NSManagedObject>(sorting: [NSSortDescriptor]? = nil) -> [Entity] {
        let request: NSFetchRequest<Entity> = fetcher()
        request.sortDescriptors = sorting
        return fetchAssertNoThrow(request)
    }
    
    /**
     Fetch, assuming that we won't throw.
     
     In debug, we use try! to deliberately crash if there was a throw.
     In release, we check the result and return an empty array if there was a throw.
     
     It's arguable whether this approach is the right way round, since it might mask a problem in release.
     
     However, there's an ulterior motive: it also avoids code coverage problems in tests. As long as
     the tests are built for debug, this code won't have an un-tested paths.
    */
    
    public func fetchAssertNoThrow<T>(_ request: NSFetchRequest<T>) -> [T] where T : NSFetchRequestResult {
        #if DEBUG
            return try! fetch(request)
        #else
        if let results = try? fetch(request) {
            return results
        }
        
        return []
        #endif
    }

    /**
     Count, assuming that we won't throw.
     
     In debug, we use try! to deliberately crash if there was a throw.
     In release, we check the result and return 0 if there was a throw.
     
     It's arguable whether this approach is the right way round, since it might mask a problem in release.
     
     However, there's an ulterior motive: it also avoids code coverage problems in tests. As long as
     the tests are built for debug, this code won't have an un-tested paths.
     */
    
    public func countAssertNoThrow<T>(_ request: NSFetchRequest<T>) -> Int where T : NSFetchRequestResult {
        #if DEBUG
        return try! count(for: request)
        #else
        if let count = try? count(for: request) {
            return count
        }
        
        return 0
        #endif
    }

}
