// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger
import Actions
import Datastore

typealias ModelEntityReference = EntityReference


extension EntityType {
    static let book: Self = "book"
    static let person: Self = "person"
    static let publisher: Self = "publisher"
    static let role: Self = "role"
    static let series: Self = "series"
    static let tag: Self = "tag"
}

extension PropertyKey {
    static let added: Self = "added"
    static let asin: Self = "asin"
    static let classification: Self = "classification"
    static let format: Self = "format"
    static let height: Self = "height"
    static let imageURL: Self = "imageURL"
    static let imageData: Self = "imageData"
    static let importDate: Self = "importDate"
    static let importedModificationDate: Self = "importedModificationDate"
    static let importRaw: Self = "importRaw"
    static let isbn: Self = "isbn"
    static let length: Self = "length"
    static let locked: Self = "locked"
    static let modified: Self = "modified"
    static let notes: Self = "notes"
    static let published: Self = "published"
    static let publisher: Self = "publisher"
    static let source: Self = "source"
    static let subtitle: Self = "subtitle"
    static let width: Self = "width"
}

extension PropertyType {
    static let author: Self = "author"
    static let editor: Self = "editor"
    static let publisher: Self = EntityType.publisher.asPropertyType
    static let series: Self = EntityType.series.asPropertyType
    static let tag: Self = EntityType.tag.asPropertyType
    static let role: Self = "role"
}

extension PropertyDictionary {
    mutating func extract(nonZeroDoubleWithKey fromKey: String, from data: [String:Any], intoKey key: PropertyKey) {
          if let value = data[fromKey] as? Double, value > 0 {
               self[key] = value
           }
    }
    
    mutating func extract(stringWithKey fromKey: String, from data: [String:Any], intoKey key: PropertyKey) {
        if let string = data[fromKey] as? String {
            self[key] = string
        }
    }

    mutating func extract(stringWithKeyIn fromKeys: [String], from data: [String:Any], intoKey key: PropertyKey) {
        for fromKey in fromKeys {
            if let string = data[fromKey] as? String {
                self[key] = string
                return
            }
        }
    }

    mutating func extract(dateWithKey fromKey: String, from data: [String:Any], intoKey key: PropertyKey) {
        if let date = data[fromKey] as? Date {
            self[key] = date
        }
    }
    
    mutating func extract(from data: [String:Any], stringsWithMapping mapping: [String:PropertyKey]) {
        for (fromKey, toKey) in mapping {
            extract(stringWithKey: fromKey, from: data, intoKey: toKey)
        }
    }
    
    mutating func extract(from data: [String:Any], nonZeroDoublesWithMapping mapping: [String:PropertyKey]) {
        for (fromKey, toKey) in mapping {
            extract(nonZeroDoubleWithKey: fromKey, from: data, intoKey: toKey)
        }
    }

    mutating func extract(from data: [String:Any], datesWithMapping mapping: [String:PropertyKey]) {
        for (fromKey, toKey) in mapping {
            extract(dateWithKey: fromKey, from: data, intoKey: toKey)
        }
    }

}

public extension PropertyDictionary {
    mutating func addRole(_ role: PropertyType, for entity: EntityReference) {
        let key = PropertyKey(reference: entity, name: role.name)
        self[key] = (entity, role)
    }
    
    mutating func addTag(_ tag: EntityReference) {
        let key = PropertyKey(reference: tag, name: "tag")
        self[key] = (tag, EntityType.tag.asPropertyType)
    }
    
    mutating func addPublisher(_ publisher: EntityReference) {
        let key: PropertyKey
        if ModelObject.allowMultiplePublishers {
            key = PropertyKey(reference: publisher, name: "publisher")
        } else {
            key = .publisher
        }
        self[key] = (publisher, type: EntityType.publisher.asPropertyType)
    }
}

let modelObjectChannel = Logger("com.elegantchaos.bookish.model.ModelObject")

public class ModelObject: NSManagedObject, DetailOwner {
    static let allowMultiplePublishers = false
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
