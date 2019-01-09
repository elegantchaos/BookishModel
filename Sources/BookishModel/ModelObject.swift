// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ModelObject: NSManagedObject {
    static let missingUUID = UUID() as NSUUID
    
    public var uniqueIdentifier: NSObject {
        get {
            if let uuid = self.value(forKey: "uuid") as? NSUUID {
                return uuid
            } else {
                return ModelObject.missingUUID
            }
        }
    }
}
