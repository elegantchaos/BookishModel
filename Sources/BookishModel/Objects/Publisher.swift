// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Publisher: ModelObject {
    override public class func getProvider() -> DetailProvider {
        return PublisherDetailProvider()
    }

//    public class func named(_ named: String, in context: NSManagedObjectContext) -> Publisher {
//        return self.named(named, in: context, createIfMissing: true)!
//    }
//
//    public class func named(_ named: String, in context: NSManagedObjectContext, createIfMissing: Bool) -> Publisher? {
//        let request: NSFetchRequest<Publisher> = Publisher.fetcher(in: context)
//        request.predicate = NSPredicate(format: "name = \"\(named)\"")
//        if let results = try? context.fetch(request), results.count > 0 {
//            return results[0]
//        }
//        
//        if createIfMissing {
//            let publisher = Publisher(context: context)
//            publisher.name = named
//            return publisher
//        }
//        
//        return nil
//    }
    
    public override func didChangeValue(forKey key: String) { // TODO: not sure that this is the best approach...
        if key == "name" {
            sortName = Indexing.titleSort(for: name)
        }
        super.didChangeValue(forKey: key)
    }
    
    @objc dynamic var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }

}
