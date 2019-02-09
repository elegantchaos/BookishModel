// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger

let modelObjectChannel = Logger("com.elegantchaos.bookish.ModelObject")

public class ModelObject: NSManagedObject {
    static let missingUUID = "missing-identifier" as NSString

    public var uniqueIdentifier: NSObject {
        get {
            if let uuid = self.value(forKey: "uuid") as? NSString {
                return uuid
            } else {
                return ModelObject.missingUUID
            }
        }
    }
    
    public override func awakeFromInsert() {
        assignInitialUUID()
    }

    func assignInitialUUID() {
        setValue(UUID().uuidString, forKey: "uuid")
    }
    
    
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
