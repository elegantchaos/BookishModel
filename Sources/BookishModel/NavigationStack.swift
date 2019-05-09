// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class NavigationStack<ItemType> {
    var stack: [ItemType]
    var position: Array<ItemType>.Index
    
    init() {
        stack = []
        position = stack.endIndex
    }
    
    func push(_ item: ItemType) {
        let count = stack.endIndex - position
        stack.removeLast(count)
        stack.append(item)
        position = stack.endIndex
    }
    
}
