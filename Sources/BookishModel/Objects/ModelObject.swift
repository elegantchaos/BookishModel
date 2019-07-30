// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger
import Actions

let modelObjectChannel = Logger("com.elegantchaos.bookish.model.ModelObject")

public class ModelObject: NSManagedObject, DetailOwner {
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
     Entity name. The same as the name of the dynamic type.
    */
    
    public class var entityName: String {
        return String(describing: self)
    }
    
    /**
     Label describing the category for the entity.
     Subclasses should override.
     */
    
    public class var entityLabel: String {
        let entityName = String(describing: self)
        return "\(entityName).label".localized
    }

    /**
     Title describing the category for the entity.
     Subclasses should override.
     */
    
    public class var entityTitle: String {
        let entityName = String(describing: self)
        return "\(entityName).title".localized
    }

    /**
     Placeholder image name.
     */
    
    public class var entityPlaceholder: String {
        return "\(self)Placeholder"
    }
    
    /**
     Return a count string for the entity. The exact text is pulled from the translation,
     but is generally of the form "x entit(y/ies)", or "no entities".
    */
    
    public class func entityCount(_ count: Int, selected: Int = 0, prefix: String = "count") -> String {
        var key = "\(self).\(prefix)."
        if count > 0 && count == selected {
            key += "all"
        } else {
            switch count {
                case 0: key += "none"
                case 1: key += "singular"
                default: key += "plural"
            }
        }
        
        return key.localized(with: ["count": count, "selected": selected])
    }

    public class func getProvider() -> DetailProvider {
        return DetailProvider()
    }

    @objc public var summary: String? {
        return nil
    }
    
    public override var description: String {
        if let asEntity = self as? ModelEntityCommon {
            return "<\(type(of:self).entityName): \(asEntity.nameAndId)>"
        } else {
            return "<\(type(of:self).entityName)>"
        }
    }

}

// MARK: Selection Support

public typealias ModelSelection = Selection<ModelEntity>

// MARK: Action Serialization Support

extension ModelObject: ActionSerialization {
    public var serialized: Any {
        return self.uniqueIdentifier as! String
    }
}

