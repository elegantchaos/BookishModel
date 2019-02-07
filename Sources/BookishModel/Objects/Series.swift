// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Series: ModelObject {
    
    public override class var categoryLabel: String { return "Series" }

    public class func named(_ named: String, in context: NSManagedObjectContext) -> Series? {
        let request: NSFetchRequest<Series> = Series.fetcher(in: context)
        request.predicate = NSPredicate(format: "name = \"\(named)\"")
        if let results = try? context.fetch(request), results.count > 0 {
            return results[0]
        }
        
        return nil
    }
    
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
