// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ModelObject: NSManagedObject {
    static let missingUUID = UUID() as NSUUID
    
    convenience init(in context: NSManagedObjectContext) {
//        let entityName = "\(type(of: self))" // TODO: there must be a cleaner way...
//        let description = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]!
        let description = ModelObject.desc(for: type(of: self), context: context)
        self.init(entity: description, insertInto: context)
    }
    
    public class func desc<T>(for type: T, context: NSManagedObjectContext) -> NSEntityDescription {
        let name = "\(type)"
        let description = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[name]!
        return description!
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
    
    public class func fetcher<T>(in context: NSManagedObjectContext) -> NSFetchRequest<T> where T: ModelObject {
        let description = T.desc(for: T.self, context: context)
//        let entityName = "\(T.self)" // TODO: there must be a cleaner way...
//        let description = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]!
        let request = NSFetchRequest<T>()
        request.entity = description
        return request
    }
}
