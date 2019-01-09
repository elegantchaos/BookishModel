// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData


public class Book: ModelObject, UniqueModelObject {
    
    static var untitledCount = 0

    public var uniqueIdentifier: NSObject {
        return self.uuid! as NSUUID
    }

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
    
    @objc public var identifier: String? {
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
