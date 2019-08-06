// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions

public class ModelEntity: ModelObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        var count = 1
        let entityName = type(of: self).entityName
        var name = "Untitled \(entityName)"
        repeat {
            let existing = type(of: self).named(name, in: self.managedObjectContext!, createIfMissing: false)
            if existing == nil {
                break
            }
            count += 1
            name = "Untitled \(entityName) \(count)"
        } while (true)
        
        let asEntity = self as! ModelEntityCommon
        let now = Date()
        asEntity.name = name
        asEntity.added = now
        asEntity.modified = now
    }
    
    public override func didChangeValue(forKey key: String) { // TODO: not sure that this is the best approach...
        switch key {
            
        case "sortName", "modified":
            break
            
        case "name":
            updateSortName()
            fallthrough
            
        default:
            setPrimitiveValue(Date(), forKey: "modified")
        }
        
        super.didChangeValue(forKey: key)
    }
    
    public func updateSortName() {
    }

    public override var description: String {
        return "<\(type(of:self).entityName): \((self as! ModelEntityCommon).nameAndId)>"
    }
}


// MARK: Selection Support

public typealias ModelSelection = Selection<ModelEntity>

// MARK: Action Serialization Support

extension ModelEntity: ActionSerialization {
    public var serialized: Any {
        return self.uniqueIdentifier as! String
    }
}


/**
 All ModelEntity subclasses should conform to this protocol.
 ModelEntity itself doesn't, because the properties that it defines are declared on
 the subclasses by the CoreData integration, and so defining them
 
 */

public protocol ModelEntityCommon: ModelEntity {
    var name: String? { get set }
    var uuid: String? { get set }
    var imageData: Data? { get set }
    var imageURL: String? { get set }
    var added: Date? { get set }
    var modified: Date? { get set }
}

extension ModelEntityCommon {
    public var nameAndId: String {
        var result = name ?? "<unknown>"
        if let uuid = uuid {
            result += " (\(uuid))"
        }
        return result
    }
    
}


public protocol ModelEntitySortable: ModelEntity {
    var sortName: String? { get set }
}

// TODO: Move ImageView into BookishCore? Or move it and ImageFactory into separate Images library

public protocol ImageView: NSObject {
    associatedtype ImageType
    
    var image: ImageType? { get set }
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


extension ModelEntityCommon {
    public func setImage<View: ImageView, Factory: ImageFactory>(for view: View, cache: ImageCache<Factory>, callback: ((Factory.ImageClass) -> Void)? = nil) where Factory.ImageClass == View.ImageType {
        if let data = imageData, let image = Factory.image(from: data) {
            view.image = image
        } else {
            view.image = Factory.image(named: type(of: self).entityPlaceholder)
            if let urlString = imageURL, let url = URL(string: urlString) {
                cache.image(for: url) { (image) in
                    view.image = image
                    callback?(image)
                }
            }
        }
    }

}
