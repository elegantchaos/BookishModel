// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData


public class Book: ModelObject {
    
    static var untitledCount = 0

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        name = "Untitled \(Book.untitledCount)"
        Book.untitledCount += 1
        
        added = Date()
        modified = Date()
    }

    public var roles: Set<Role> {
        var result = Set<Role>()
        if let people = self.relationships as? Set<Relationship> {
            for entry in people {
                if let role = entry.role {
                    result.insert(role)
                }
            }
        }
        
        return result
    }

    public var people: Set<Person> {
        var result = Set<Person>()
        if let people = self.relationships as? Set<Relationship> {
            for entry in people {
                if let person = entry.person {
                    result.insert(person)
                }
            }
        }
        
        return result
    }

    @objc public var dimensions: String? {
        guard width > 0 || height > 0 || length > 0 else {
            return nil
        }
        
        return "\(width) x \(height) x \(length)"
    }
    
    /**
      Remove this book from a series.
    */
    
    public func removeFromSeries(_ series: Series) {
        if let entries = entries as? Set<SeriesEntry> {
            for entry in entries {
                if entry.series == series {
                    removeFromEntries(entry)
                    assert(entry.isDeleted)
                }
            }
        }
    }
    
    /**
     Add an entry for this book to a series.
     A book shouldn't be listed more than once in the same series, so we check first
     to see if there's already a listing. If there is, we just update the position.
    */
    
    public func addToSeries(_ series: Series, position: Int) {
        if let entries = entries as? Set<SeriesEntry> {
            for entry in entries {
                if entry.series == series {
                    entry.position = Int16(position)
                    return
                }
            }
        }
        
        let entry = SeriesEntry(context: self.managedObjectContext!)
        entry.series = series
        entry.position = Int16(position)
        addToEntries(entry)
    }
    
    /**
     Return the position of this book in a given series.
     Returns 0 if the book isn't in the series (or has an entry but no known position).
    */
    
    public func position(in series: Series) -> Int {
        if let entries = entries as? Set<SeriesEntry> {
            for entry in entries {
                if entry.series == series {
                    return Int(entry.position)
                }
            }
        }
        
        return 0
    }
    
    
    @objc public var identifier: String? {
        get {
        var result = [String]()
        var separateASIN = true
        
        if let isbn = isbn {
            let tag: String
            if let asin = asin, isbn == asin {
                separateASIN = false
                tag = "isbn/asin"
            } else {
                tag = "isbn"
            }
            if !isbn.isEmpty {
                result.append("\(isbn) (\(tag))")
            }
        }
        
        if let ean = ean, !ean.isEmpty {
            result.append("\(ean) (ean)")
        }

        if separateASIN, let asin = asin, !asin.isEmpty {
            result.append("\(asin) (asin)")
        }

        return result.joined(separator: "\n")
    }
        
        set {
            
        }
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
