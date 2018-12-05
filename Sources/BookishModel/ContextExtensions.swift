// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

extension NSManagedObjectContext {
    public func everyEntity<Entity: NSManagedObject>() -> [Entity] {
        let request: NSFetchRequest<Entity> = Entity.fetchRequest() as! NSFetchRequest<Entity>
        if let results = try? fetch(request) {
            return results
        }
        
        return []
    }

    
}
