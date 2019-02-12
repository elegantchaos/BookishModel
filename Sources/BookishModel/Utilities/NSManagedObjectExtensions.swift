// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

/**
 Generic which gets an existing entity of a given name and type, or creates one if necessary.
 */

internal func getNamed<EntityType: NSManagedObject>(_ named: String, type: EntityType.Type, in context: NSManagedObjectContext, createIfMissing: Bool) -> EntityType? {
    let request: NSFetchRequest<EntityType> = EntityType.fetcher(in: context)
    request.predicate = NSPredicate(format: "name = \"\(named)\"")
    if let results = try? context.fetch(request), let object = results.first {
        return object
    }
    
    if createIfMissing {
        let description = EntityType.entityDescription(for: EntityType.self, in: context)
        if let object = NSManagedObject(entity: description, insertInto: context) as? EntityType {
            object.setValue(named, forKey: "name")
            return object
        }
    }
    
    return nil
}

extension NSManagedObject {
    /**
     Return the entity of our type with a given name, or make it if it doesn't exist.
    */
    
    public class func named(_ named: String, in context: NSManagedObjectContext) -> Self {
        return getNamed(named, type: self, in: context, createIfMissing: true)!
    }
    
    /**
     Return the entity of our type with a given name.
     If it doesn't exist, we optionally create it, or return nil.
    */
    
    public class func named(_ named: String, in context: NSManagedObjectContext, createIfMissing: Bool) -> Self? {
        return getNamed(named, type: self, in: context, createIfMissing: createIfMissing)
    }

    
    /**
     Make a new instance in the given context.
     
     The default implementation of this uses +entity to look up the description,
     which causes warnings if more than once copy of the model has been loaded.
     
     We override it here and instead use the context we were given to look it up in the
     actual model that the context is using.
     */
    
    public convenience init(in context: NSManagedObjectContext) {
        let description = NSManagedObject.entityDescription(for: type(of: self), in: context)
        self.init(entity: description, insertInto: context)
    }
    
    /**
     Return an NSFetchRequest for a given model object class.
     
     Xcode generates a `fetchRequest` method which does pretty much the same thing,
     but it uses +entity to find the entity description.
     
     This version takes in the context and uses that to look up the description in the model.
     */
    
    public class func fetcher<T>(in context: NSManagedObjectContext) -> NSFetchRequest<T> where T: NSManagedObject {
        let request = NSFetchRequest<T>()
        request.entity = T.entityDescription(for: T.self, in: context)
        return request
    }
    
    /**
     Return the entity description for a given model class, using the mode from the supplied context to find it.
     */
    
    public class func entityDescription<T>(for type: T, in context: NSManagedObjectContext) -> NSEntityDescription {
        let name = String(describing: type)
        guard let coordinator = context.persistentStoreCoordinator else {
            modelObjectChannel.fatal("missing coordinator")
        }
        
        guard let description = coordinator.managedObjectModel.entitiesByName[name] else {
            modelObjectChannel.fatal("no entity named \(name)")
        }
        
        return description
    }
    
    /**
     Return the entity description for this instance.
     */
    
    public func entityDescription() -> NSEntityDescription {
        guard let context = managedObjectContext else {
            fatalError("no context")
        }
        
        return NSManagedObject.entityDescription(for: type(of: self), in: context)
    }

}