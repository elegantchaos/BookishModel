// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let navigationStackChannel = Logger("com.elegantchaos.bookish.model.NavigationStack")

class NavigationStack<ItemType> {
    var stack: [ItemType]

    var position: Int
    
    var current: ItemType? {
        if stack.count == 0 {
            return nil
        } else {
            return stack[position - 1]
        }
    }

    init() {
        stack = []
        position = 0
    }

    func push(_ item: ItemType) {
        navigationStackChannel.log("Adding item \(item). Current position \(position).")
        let count = stack.count - position
        stack.removeLast(count)
        stack.append(item)
        position = stack.count
        navigationStackChannel.log("New position \(position)")
    }
    
    func goBack() -> Bool {
        guard position > 1 else {
            return false
        }

        position -= 1
        return true
    }

    func goForward() -> Bool {
        guard position < stack.count else {
            return false
        }
        
        position += 1
        return true
    }
}
