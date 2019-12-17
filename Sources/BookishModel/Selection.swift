// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import Foundation

public class Selection<T: ModelEntityReference> {
    public var objects: [T]
    
    public var count: Int {
        return objects.count
    }
    
    public init() {
        self.objects = []
    }
    
    public init(_ objects: [T]) {
        self.objects = objects
    }
    
    public func value(forKey key: String) -> BoundValue {
        switch objects.count {
        case 0:
            return .noSelection
        case 1:
            let object = objects.first!
            let value = object[PropertyKey(key)]
            return .value(value: value, source: object)
        default:
            let value = objects.first![PropertyKey(key)] as? NSObject
            for item in objects {
                let nextValue = item[PropertyKey(key)] as? NSObject
                if nextValue != value {
                    return .multipleValues
                }
            }
            return .value(value: value, source: nil)
        }
    }

    public func singleValue(forKey key: String) -> Any? {
        let value = self.value(forKey: key)
        switch value {
        case .value(let value):
            return value
        default:
            return nil
        }
    }

    public func proxy(withUniformKeys keys: [String]) -> Any? {
        for key in keys {
            let value = self.value(forKey: key)
            switch value {
            case .value(_, let object):
                return object
            default:
                break
            }
        }
        return nil
    }
    
    public func clear() {
        self.objects = []
    }
    
    public func set(to objects: [T]) {
        self.objects = objects
    }
    
    public func set(from indexes: IndexSet, of allObjects: [T]) {
        objects.removeAll()
        for index in indexes {
            objects.append(allObjects[index])
        }
    }
    
    public func indexes(in allObjects: [T]) -> IndexSet {
        var indexes = IndexSet()
        for object in objects {
            if let index = allObjects.firstIndex(of: object) {
                indexes.insert(index)
            }
        }
        return indexes
    }
}
