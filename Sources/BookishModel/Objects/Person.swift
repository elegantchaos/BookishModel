// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Person: ModelObject {
    
    public override class var categoryLabel: String { return "People" }

    public class func named(_ name: String, in context: NSManagedObjectContext, creating: Bool = false) -> Person? {
        let request: NSFetchRequest<Person> = Person.fetcher(in: context)
        request.predicate = NSPredicate(format: "name = \"\(name)\"")
        if let results = try? context.fetch(request), results.count > 0 {
            return results[0]
        }
        
        if creating {
            let person = Person(context: context)
            person.name = name
            return person
        }
        return nil
    }
    
    /**
     If there's already an entry for a given role name for this person, return it.
     If not, create it.
     */
    
    public func relationship(as roleName: String) -> Relationship {
        let context = self.managedObjectContext!
        let role = Role.named(roleName, in: context)
        return relationship(as: role)
    }

    /**
     If there's already an entry for a given role for this person, return it.
     If not, create it.
     */
    
    public func relationship(as role: Role) -> Relationship {
        let context = self.managedObjectContext!
        let request: NSFetchRequest<Relationship> = Relationship.fetcher(in: context)
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

    public override func didChangeValue(forKey key: String) { // TODO: not sure that this is the best approach...
        if key == "name" {
            sortName = Indexing.nameSort(for: name)
        }
        super.didChangeValue(forKey: key)
    }
    
    @objc dynamic var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }

}
