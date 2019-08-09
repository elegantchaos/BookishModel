// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Person: ModelEntity, ModelEntityCommon {

    override public class func getProvider() -> DetailProvider {
        return PersonDetailProvider()
    }

    /**
     If there's already an entry for a given role name for this person, return it.
     If not, create it.
     */

    public func relationship(as roleName: Role.StandardName) -> Relationship {
        return relationship(as: roleName.rawValue)
    }

    /**
     If there's already an entry for a given role name for this person, return it.
     If not, create it.
     */
    
    public func relationship(as roleName: String) -> Relationship {
        let context = self.managedObjectContext!
        let role: Role = Role.named(roleName, in: context)
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
    
    
    /// Return the relationship for this person, for the given role, if it exists.
    /// - Parameter role: role we're looking for
    public func existingRelationship(as role: Role) -> Relationship? {
        if let relationships = self.relationships as? Set<Relationship> {
            for relationship in relationships {
                if relationship.role == role {
                    return relationship
                }
            }
        }
        return nil
    }


    public func summaryItems() -> [String] {
        var details: [String] = []

        if let relationships = relationships as? Set<Relationship> {
            var allBooks: Set<Book> = []
            for relationship in relationships {
                allBooks.formUnion(relationship.books)
            }
            let names = allBooks.compactMap({ $0.name })
            details.append(contentsOf: names)
        }

        return details
    }

    override public func updateSortName() {
        sortName = Indexing.nameSort(for: name)
    }
    
    @objc dynamic var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }


}
