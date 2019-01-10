// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ModelObject: NSManagedObject {
    static let missingUUID = UUID() as NSUUID

    public var uniqueIdentifier: NSObject {
        get {
            if let uuid = self.value(forKey: "uuid") as? NSUUID {
                return uuid
            } else {
                return ModelObject.missingUUID
            }
        }
    }
    

    /**
        Make a new instance in the given context.
 
        The default implementation of this uses +entity to look up the description,
        which causes warnings if more than once copy of the model has been loaded.
 
        We override it here and instead use the context we were given to look it up in the
        actual model that the context is using.
     */
    
    public convenience init(context: NSManagedObjectContext) {
        let description = ModelObject.entityDescription(for: type(of: self), in: context)
        self.init(entity: description, insertInto: context)
    }
    
    /**
        Return an NSFetchRequest for a given model object class.
 
        Xcode generates a `fetchRequest` method which does pretty much the same thing,
        but it uses +entity to find the entity description.
 
        This version takes in the context and uses that to look up the description in the model.
     */
    
    public class func fetcher<T>(in context: NSManagedObjectContext) -> NSFetchRequest<T> where T: ModelObject {
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
            fatalError("missing coordinator")
        }
        
        guard let description = coordinator.managedObjectModel.entitiesByName[name] else {
            fatalError("no entity named \(name)")
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
        
        return ModelObject.entityDescription(for: type(of: self), in: context)
    }
}
