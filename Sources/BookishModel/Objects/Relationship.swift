// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Relationship: ModelObject {
    
    /**
     We should only have one entry for a given person/role pair, so the uuid is derived from their uuids.
     */
    
    public override var uniqueIdentifier: NSObject {
        guard let personID = person?.uuid, let roleID = role?.uuid else {
            return ModelObject.missingUUID
        }
        
        return "\(personID)-\(roleID)" as NSString
    }

    /**
     Since the uuid is calculated, we don't need to assign one initially.
     */
    
    override func assignInitialUUID() {
    }

    public override var description: String {
        let roleName = role?.name ?? "<unknown>"
        var personName = person?.name ?? "<unknown>"
        if let uuid = person?.uuid {
           personName += " (\(uuid))"
        }
        let bookList: String
        if let books = books as? Set<Book>, books.count > 0 {
            bookList = " with " + books.map({ $0.nameAndId }).joined(separator: ",")
        } else {
            bookList = ""
        }
        
        return "<Relationship: \(roleName) for \(personName)\(bookList)>"
    }

}
