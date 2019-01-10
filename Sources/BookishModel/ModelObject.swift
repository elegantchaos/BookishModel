// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ModelObject: NSManagedObject {
    static let missingUUID = UUID() as NSUUID
    
    public convenience init(context: NSManagedObjectContext) {
        let description = ModelObject.entityDescription(for: type(of: self), in: context)
        self.init(entity: description, insertInto: context)
    }
    
    public class func fetcher<T>(in context: NSManagedObjectContext) -> NSFetchRequest<T> where T: ModelObject {
        let request = NSFetchRequest<T>()
        request.entity = T.entityDescription(for: T.self, in: context)
        return request
    }

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
    
    public var uniqueIdentifier: NSObject {
        get {
            if let uuid = self.value(forKey: "uuid") as? NSUUID {
                return uuid
            } else {
                return ModelObject.missingUUID
            }
        }
    }
    
    public func entityDescription() -> NSEntityDescription {
        guard let context = managedObjectContext else {
            fatalError("no context")
        }
        
        return ModelObject.entityDescription(for: type(of: self), in: context)
    }
}
