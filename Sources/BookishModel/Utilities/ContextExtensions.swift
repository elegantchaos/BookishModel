// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

extension NSManagedObjectContext {
    
    /**
     Return every instance of a given entity type.
    */
    
    public func everyEntity<Entity: NSManagedObject>(sorting: [NSSortDescriptor]? = nil) -> [Entity] {
        let request: NSFetchRequest<Entity> = Entity.fetchRequest() as! NSFetchRequest<Entity>
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

}
