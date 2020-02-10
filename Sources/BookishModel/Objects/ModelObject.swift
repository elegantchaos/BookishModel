// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger
import Actions
import Datastore

public typealias ModelEntityReference = EntityReference

public extension DatastoreType {
    static let book: Self = "book"
    static let person: Self = "person"
    static let publisher: Self = "publisher"
    static let role: Self = "role"
    static let series: Self = "series"
    static let tag: Self = "tag"
    static let author: Self = "author"
    static let editor: Self = "editor"
}

public extension PropertyKey {
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
    static let sortName: Self = "sortName"
    static let source: Self = "source"
    static let subtitle: Self = "subtitle"
    static let width: Self = "width"
}

public extension PropertyDictionary {
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
    static func keyForRole(_ role: DatastoreType, for entity: EntityReference) -> PropertyKey {
        return PropertyKey(reference: entity, name: role.name)
    }
    
    static func withRole(_ role: DatastoreType, for entity: EntityReference) -> PropertyDictionary {
        var properties = PropertyDictionary()
        properties.addRole(role, for: entity)
        return properties
    }
    
    mutating func addRole(_ role: DatastoreType, for entity: EntityReference) {
        let key = PropertyDictionary.keyForRole(role, for: entity)
        self[key] = (entity, role)
    }
    
    mutating func addTag(_ tag: EntityReference) {
        let key = PropertyKey(reference: tag, name: "tag")
        self[key] = (tag, DatastoreType.tag)
    }
    
    mutating func addPublisher(_ publisher: EntityReference) {
        let key: PropertyKey
        if ModelObject.allowMultiplePublishers {
            key = PropertyKey(reference: publisher, name: "publisher")
        } else {
            key = .publisher
        }
        self[key] = (publisher, type: DatastoreType.publisher)
    }
}

let modelObjectChannel = Logger("com.elegantchaos.bookish.model.ModelObject")
//


public class ModelObject: CustomReference, DetailOwner {
    static let allowMultiplePublishers = false

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
     
     public var summary: String? {
         return nil
     }
     
    public var name: String? {
        return self[.name] as? String
    }

    public var sortName: String? {
        get { return self[.sortName] as? String }
        set { self[.sortName] = newValue }
    }

    public var uuid: String? {
        return self.identifier
    }
    
    public var nameAndId: String {
        var result = name ?? "<unknown>"
        if let uuid = uuid {
            result += " (\(uuid))"
        }
        return result
    }

     public var description: String {
        let type = Swift.type(of:self)
        return "<\(type.entityName): \(nameAndId)>"
     }
     
     public var imageData: Data? {
         get { self[.imageData] as? Data }
     }
     
    public var imageURL: String? {
        get { self[.imageURL] as? String }
    }
    
     public func setImage<View: ImageView, Factory: ImageFactory>(for view: View, cache: ImageCache<Factory>, missingMode: ImageMissingMode = .placeholder, callback: ((Factory.ImageClass) -> Void)? = nil) where Factory.ImageClass == View.ImageType {
         if let data = imageData, let image = Factory.image(from: data) {
             view.image = image
             view.isHidden = false
         } else {
             switch missingMode {
                 case .hide:
                     view.isHidden = true
                 case .empty:
                     view.image = nil
                 case .placeholder:
                    view.image = Factory.image(named: Swift.type(of: self).entityPlaceholder)
             }
             
             if let urlString = imageURL, let url = URL(string: urlString) {
                 cache.image(for: url) { (image) in
                     view.image = image
                     view.isHidden = false
                     callback?(image)
                 }
             }
         }
     }
     
         public func updateSortName() {
         }


}
//    static let missingUUID = "missing-identifier" as NSString
//
//    /**
//     Return a unique identifier as an NSObject
//     (handy for Ensembles, which wants one in this format).
//     
//     We return the uuid property for those entities that have one,
//     or a default id otherwise. Some model subclasses override to
//     do their own thing.
//    */
//    
//    public var uniqueIdentifier: NSObject {
//        get {
//            if let uuid = self.value(forKey: "uuid") as? NSString {
//                return uuid
//            } else {
//                return ModelObject.missingUUID
//            }
//        }
//    }
//    
//    /**
//     Automitically assign a uuid on insertion.
//    */
//    
//    public override func awakeFromInsert() {
//        assignInitialUUID()
//    }
//
//    /**
//     Assign a random uuid.
//     */
//    
//    func assignInitialUUID() {
//        setValue(UUID().uuidString, forKey: "uuid")
//    }
//    
//    /**
//     Override the default initialiser with one that safely looks up the entity in the context.
//    */
//    
//    public convenience init(context: NSManagedObjectContext) {
//        self.init(in: context)
//    }
//    
//
//}

//    public override func awakeFromInsert() {
//        super.awakeFromInsert()
//
//        var count = 1
//        let entityName = type(of: self).entityName
//        var name = "Untitled \(entityName)"
//        repeat {
//            let existing = type(of: self).named(name, in: self.managedObjectContext!, createIfMissing: false)
//            if existing == nil {
//                break
//            }
//            count += 1
//            name = "Untitled \(entityName) \(count)"
//        } while (true)
//
//        let asEntity = self as! ModelEntityCommon
//        let now = Date()
//        asEntity.name = name
//        asEntity.added = now
//        asEntity.modified = now
//    }
//
//    public override func didChangeValue(forKey key: String) { // TODO: not sure that this is the best approach...
//        switch key {
//
//        case "sortName", "modified":
//            break
//
//        case "name":
//            updateSortName()
//            fallthrough
//
//        default:
//            setPrimitiveValue(Date(), forKey: "modified")
//        }
//
//        super.didChangeValue(forKey: key)
//    }
//
//    public override var description: String {
//        return "<\(type(of:self).entityName): \((self as! ModelEntityCommon).nameAndId)>"
//    }
//}
//
//
//// MARK: Selection Support
//
public class ModelSelection : Selection<ModelEntityReference> {
    //    public var uuids: [String] {
    //        return objects.compactMap { ($0 as! ModelEntityCommon).uuid }
    //    }
}
//
//// MARK: Action Serialization Support
//
//extension ModelObject: ActionSerialization {
//    public var serialized: Any {
//        return self.uniqueIdentifier as! String
//    }
//}
//
//
///**
// All ModelObject subclasses should conform to this protocol.
// ModelObject itself doesn't, because the properties that it defines are declared on
// the subclasses by the CoreData integration, and so defining them
//
// */
//
//public protocol ModelEntityCommon: ModelObject {
//    var name: String? { get set }
//    var uuid: String? { get set }
//    var imageData: Data? { get set }
//    var imageURL: String? { get set }
//    var added: Date? { get set }
//    var modified: Date? { get set }
//}
//
//extension ModelEntityCommon {
//
//}
//

public protocol ModelEntitySortable: ModelObject {
    var sortName: String? { get set }
}

//// TODO: Move ImageView into BookishCore? Or move it and ImageFactory into separate Images library

public protocol ImageView: NSObject {
    associatedtype ImageType
    
    var image: ImageType? { get set }
    var isHidden: Bool { get set }
}

#if os(iOS)

import UIKit

extension UIImageView: ImageView {
    public typealias ImageType = UIImage
}

#endif

#if os(macOS)

import AppKit

extension NSImageView: ImageView {
    public typealias ImageType = NSImage
}

#endif

public enum ImageMissingMode {
    case placeholder
    case empty
    case hide
}

