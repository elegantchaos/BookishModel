// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let navigationStackChannel = Logger("com.elegantchaos.bookish.model.NavigationStack")

class NavigationStack<ItemType> {
    var stack: [ItemType]

    var position: Array<ItemType>.Index
    
    var current: ItemType? {
        if stack.count == 0 {
            return nil
        } else {
            return stack[position - 1]
        }
    }

    init() {
        stack = []
        position = stack.startIndex
    }

    func push(_ item: ItemType) {
        navigationStackChannel.log("Added item \(item) at \(position)")
        let count = stack.endIndex - position
        stack.removeLast(count)
        stack.append(item)
        position = stack.endIndex
    }
    
    func goBack() -> Bool {
        guard position != stack.startIndex else {
            return false
        }

        position -= 1
        return true
    }

    func goForward() -> Bool {
        guard position != stack.endIndex else {
            return false
        }
        
        position += 1
        return true
    }
}
