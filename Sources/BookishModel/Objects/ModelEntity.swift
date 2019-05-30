// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


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
        
        let now = Date()
        setValue(name, forKey: "name")
        setValue(now, forKey: "added")
        setValue(now, forKey: "modified")
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
}

public protocol ModelEntityCommon: ModelEntity {
    var name: String? { get set }
    var uuid: String? { get set }
    var imageData: Data? { get set }
    var imageURL: String? { get set }
    var added: Date? { get set }
    var modified: Date? { get set }
}

public protocol ModelEntitySortable: ModelEntity {
    var sortName: String? { get set }
}
