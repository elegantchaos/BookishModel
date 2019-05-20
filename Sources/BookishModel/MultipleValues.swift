// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct MultipleValues<ValueType> where ValueType: Hashable {
    let all: Set<ValueType>
    let common: Set<ValueType>

    /**
     Extract items from a selection of entities.
     We take a function which obtains a set of items to consider for a given book.
     We get back a struct containing two sets:
     - all: the items that were present for any book
     - common: the items that were present for every book
     */
    
    static public func extract<ItemType>(from selection: [ItemType], extractor: (ItemType) -> Set<ValueType>?) -> MultipleValues<ValueType> {
        var all = Set<ValueType>()
        var common = Set<ValueType>()
        for entity in selection {
            if let items = extractor(entity) {
                if all.count == 0 {
                    common.formUnion(items)
                } else {
                    common.formIntersection(items)
                }
                all.formUnion(items)
            }
        }
        return MultipleValues(all: all, common: common)
    }
    
}

