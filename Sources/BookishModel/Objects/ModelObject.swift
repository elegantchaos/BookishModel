// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger

let modelObjectChannel = Logger("com.elegantchaos.bookish.model.ModelObject")

public class ModelObject: NSManagedObject {
    static let missingUUID = "missing-identifier" as NSString

    /**
     Return a unique identifier as an NSObject
     (handy for Ensembles, which wants one in this format).
     
     We return the uuid property for those entities that have one,
     or a default id otherwise. Some model subclasses override to
     do their own thing.
    */
    
    public var uniqueIdentifier: NSObject {
        get {
            if let uuid = self.value(forKey: "uuid") as? NSString {
                return uuid
            } else {
                return ModelObject.missingUUID
            }
        }
    }
    
    /**
     Automitically assign a uuid on insertion.
    */
    
    public override func awakeFromInsert() {
        assignInitialUUID()
    }

    /**
     Assign a random uuid.
     */
    
    func assignInitialUUID() {
        setValue(UUID().uuidString, forKey: "uuid")
    }
    
    /**
     Override the default initialiser with one that safely looks up the entity in the context.
    */
    
    public convenience init(context: NSManagedObjectContext) {
        self.init(in: context)
    }
    
    /**
     Label describing the category for the entity.
     Subclasses should override.
     */
    
    public class var categoryLabel: String { return "unknown" }
    
    /**
     Placeholder image name.
     */
    
    public class var categoryPlaceholderName: String { return "\(self)Placeholder" }
    
}
