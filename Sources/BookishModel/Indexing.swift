// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

class Indexing {
    
    class func sectionName(for name: String?) -> String? {
        if let c = name?.first {
            return String(c)
        }
        
        return nil
    }
    
    class func titleSort(for name: String?) -> String? {
        if let name = name {
            if name.starts(with: "The ") {
                let index = name.index(name.startIndex, offsetBy: 4)
                return String(name[index...])
            }
        }
        
        return name
    }

    class func nameSort(for name: String?) -> String? {
        if let name = name {
            let words = name.split(separator: " ")
            let count = words.count
            if count > 1 {
                let tail = words[...(count - 2)].joined(separator: " ")
                if let last = words.last {
                    return "\(last), \(tail)"
                }
            }
        }
        
        return name
    }

}
