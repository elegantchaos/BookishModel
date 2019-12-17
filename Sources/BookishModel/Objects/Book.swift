// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Datastore

let bookChannel = Channel("com.elegantchaos.bookish.model.book")

public typealias Book = EntityReference
//
//public class Book: ModelEntity, ModelEntityCommon {
//
//    static let notFound = 1
//
//    override public class func getProvider() -> DetailProvider {
//        return BookDetailProvider()
//    }
//
//    public var roles: Set<Role> {
//        var result = Set<Role>()
//        if let people = self.relationships as? Set<Relationship> {
//            for entry in people {
//                if let role = entry.role {
//                    result.insert(role)
//                }
//            }
//        }
//
//        return result
//    }
//
//    public var people: Set<Person> {
//        var result = Set<Person>()
//        if let people = self.relationships as? Set<Relationship> {
//            for entry in people {
//                if let person = entry.person {
//                    result.insert(person)
//                }
//            }
//        }
//
//        return result
//    }
//
//    @objc public var dimensions: Array<Double>? {
//        guard width > 0 || height > 0 || length > 0 else {
//            return nil
//        }
//
//        return [width, height, length]
//    }
//
//    public var entries: Set<SeriesEntry> {
//        get { return entriesR as! Set<SeriesEntry> }
//        set { entriesR = newValue as NSSet }
//    }
//
//    /**
//      Remove this book from a series.
//    */
//
//    public func removeFromSeries(_ series: Series) {
//        for entry in entries {
//            if entry.series == series {
//                managedObjectContext?.delete(entry)
//                assert(entry.isDeleted)
//            }
//        }
//    }
//
//    /**
//     Add an entry for this book to a series.
//     A book shouldn't be listed more than once in the same series, so we check first
//     to see if there's already a listing. If there is, we just update the position.
//    */
//
//    @discardableResult public func addToSeries(_ series: Series, position: Int) -> SeriesEntry {
//        for entry in entries {
//            if entry.series == series {
//                entry.position = Int16(position)
//                return entry
//            }
//        }
//
//        let entry = SeriesEntry(context: self.managedObjectContext!)
//        entry.series = series
//        entry.position = Int16(position)
//        addToEntriesR(entry)
//        return entry
//    }
//
//    /**
//     Remove this book from a relationship.
//     If this was the last book in the relationship, we also delete it.
//    */
//
//    public func removeRelationship(_ relationshipToRemove: Relationship) {
//        assert(relationships?.contains(relationshipToRemove) ?? false)
//        relationshipToRemove.remove(self)
//    }
//
//
//    /// If a relationship record for the given person and role exists, return it
//    /// - Parameter person: existing person
//    /// - Parameter role: existing role
//    public func existingRelationship(with person: Person, as role: Role) -> Relationship? {
//        for relationship in person.relationships {
//            if relationship.role == role, relationship.books.contains(self) {
//                return relationship
//            }
//        }
//        return nil
//    }
//
//    /// Add a relationship between this book and a person/role
//    /// We ensure that we don't create a duplicate relationship object if it already exists for the person/role pair.
//    /// - Parameter person: the person
//    /// - Parameter role: the role
//    public func addRelationship(with person: Person, as role: Role) -> Relationship {
//        if let existing = person.existingRelationship(as: role) {
//            existing.add(self)
//            return existing
//        }
//
//        let relationship = Relationship(context: managedObjectContext!)
//        relationship.role = role
//        relationship.person = person
//        relationship.books = [self]
//        return relationship
//    }
//
//    /**
//     Add an entry for this book to a series.
//     A book shouldn't be listed more than once in the same series, so we check first
//     to see if there's already a listing. If there is, we just update the position.
//     */
//
//    public func setPosition(in series: Series, to position: Int) {
//        for entry in entries {
//            if entry.series == series {
//                entry.position = Int16(position)
//                return
//            }
//        }
//
//        bookChannel.fatal("book should already be in series")
//    }
//
//    /**
//     Return the position of this book in a given series.
//     Returns 0 if the book isn't in the series (or has an entry but no known position).
//    */
//
//    public func position(in series: Series) -> Int {
//        for entry in entries {
//            if entry.series == series {
//                return Int(entry.position)
//            }
//        }
//
//        return Book.notFound
//    }
//
//
//    @objc public var identifier: String? {
//        get {
//        var result = [String]()
//        var separateASIN = true
//
//        if let isbn = isbn, !isbn.isEmpty {
//            let tag: String
//            if let asin = asin, isbn == asin.isbn10to13 {
//                separateASIN = false
//                tag = "isbn/asin"
//            } else {
//                tag = "isbn"
//            }
//            result.append("\(isbn) (\(tag))")
//        }
//
//        if separateASIN, let asin = asin, !asin.isEmpty {
//            result.append("\(asin) (asin)")
//        }
//
//        return result.joined(separator: "\n")
//    }
//
//        set {
//
//        }
//    }
//
//    public override var summary: String? {
//        if let subtitle = subtitle, subtitle.count > 0 {
//            return subtitle
//        }
//
//        if entries.count > 0 {
//            let names = entries.compactMap({ (entry) -> String? in
//                if let name = entry.series?.name {
//                    if entry.position > 0 {
//                        return "\(name), Book \(entry.position)"
//                    } else {
//                        return name
//                    }
//                }
//                return nil
//            })
//
//            if names.count > 0 {
//                return names.joined(separator: ", ")
//            }
//        }
//
//        return nil
//    }
//
//    public enum SummaryMode {
//        case publisher
//        case series
//        case person
//    }
//
//    public func summaryItems(mode: SummaryMode) -> [String] {
//        var details: [String] = []
//
//        if mode != .person, let relationships = relationships as? Set<Relationship> {
//            let names = relationships.compactMap({ $0.person?.name })
//            details.append(contentsOf: names)
//        }
//
//        if let date = published {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "Y"
//            details.append(formatter.string(from: date))
//        }
//
//        if mode != .publisher, let publisher = publisher?.name {
//            details.append(publisher)
//        }
//
//        return details
//    }
//
//    override public func updateSortName() {
//        sortName = Indexing.titleSort(for: name)
//    }
//
//    @objc dynamic var sectionName: String? {
//        return Indexing.sectionName(for: sortName)
//    }
//
//    public var tags: Set<Tag> {
//        get { return tagsR as! Set<Tag> }
//        set { tagsR = newValue as NSSet }
//    }
//
//}
