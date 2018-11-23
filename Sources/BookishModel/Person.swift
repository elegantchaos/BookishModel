// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Person: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        name = "Untitled Person"
    }
    
    public class func person(named: String, context: NSManagedObjectContext) -> Person? {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "name = \"\(named)\"")
        if let results = try? context.fetch(request), results.count > 0 {
            return results[0]
        }
        
        return nil
    }
    
    /**
            If there's already an entry for a given role for this person, return it.
            If not, create it.
        */
    
    public func relationship(as roleName: String) -> Relationship {
        guard let context = self.managedObjectContext else {
            fatalError("context not set")
        }
        
        let role = Role.role(named: roleName, context: context)
        
        let request: NSFetchRequest<Relationship> = Relationship.fetchRequest()
        request.predicate = NSPredicate(format: "(person = %@) and (role = %@)", self, role)
        
        var entry: Relationship
        if let results = try? context.fetch(request), results.count > 0 {
            entry = results[0]
        } else {
            entry = Relationship(context: context)
            entry.person = self
            entry.role = role
        }
        
        return entry
    }
}