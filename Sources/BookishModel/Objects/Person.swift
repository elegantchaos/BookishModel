// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public typealias Person = EntityReference
//
//public class Person: ModelEntity, ModelEntityCommon {
//
//    override public class func getProvider() -> DetailProvider {
//        return PersonDetailProvider()
//    }
//
//    /// Set of relationships
//    /// (wraps the underlying core data NSSet as a swift Set)
//    public var relationships: Set<Relationship> {
//        get { return relationshipsR as! Set<Relationship> }
//        set { relationshipsR = newValue as NSSet }
//    }
//    
//    /// Remove a relationship
//    /// - Parameter relationship: relationship to remove
//    public func remove(_ relationship: Relationship) {
//        removeFromRelationshipsR(relationship)
//    }
//    
//    /// Return sorted list of relationships
//    /// - Parameter sort: descriptors to use for sorting
//    public func relationships(sortedBy sort: [NSSortDescriptor]) -> [Relationship] {
//        return relationshipsR?.sortedArray(using: sort) as! [Relationship]
//    }
//    
//    /**
//     If there's already an entry for a given role name for this person, return it.
//     If not, create it.
//     */
//
//    public func relationship(as roleName: Role.StandardName) -> Relationship {
//        return relationship(as: roleName.rawValue)
//    }
//
//    /**
//     If there's already an entry for a given role name for this person, return it.
//     If not, create it.
//     */
//    
//    public func relationship(as roleName: String) -> Relationship {
//        let context = self.managedObjectContext!
//        let role: Role = Role.named(roleName, in: context)
//        return relationship(as: role)
//    }
//
//    /**
//     If there's already an entry for a given role for this person, return it.
//     If not, create it.
//     */
//    
//    public func relationship(as role: Role) -> Relationship {
//        let context = self.managedObjectContext!
//        let request: NSFetchRequest<Relationship> = Relationship.fetcher(in: context)
//        request.predicate = NSPredicate(format: "(person = %@) and (role = %@)", self, role)
//        
//        var entry: Relationship
//        if let results = try? context.fetch(request), results.count > 0 {
//            entry = results[0]
//        } else {
//            entry = Relationship(context: context)
//            entry.person = self
//            entry.role = role
//        }
//        
//        return entry
//    }
//    
//    
//    /// Return the relationship for this person, for the given role, if it exists.
//    /// - Parameter role: role we're looking for
//    public func existingRelationship(as role: Role) -> Relationship? {
//        for relationship in relationships {
//            if relationship.role == role {
//                return relationship
//            }
//        }
//        return nil
//    }
//
//    /// Set of tags
//    /// (wraps the underlying core data NSSet as a swift Set)
//    public var tags: Set<Tag> {
//        get { return tagsR as! Set<Tag> }
//        set { tagsR = newValue as NSSet }
//    }
//    
//    /// Returns list of strings to include as summary information in index entries for the person.
//    public func summaryItems() -> [String] {
//        var details: [String] = []
//        var allBooks: Set<Book> = []
//        for relationship in relationships {
//            allBooks.formUnion(relationship.books)
//        }
//        let names = allBooks.compactMap({ $0.name })
//        details.append(contentsOf: names)
//
//        return details
//    }
//
//    override public func updateSortName() {
//        sortName = Indexing.nameSort(for: name)
//    }
//    
//    @objc dynamic var sectionName: String? {
//        return Indexing.sectionName(for: sortName)
//    }
//
//
//}
