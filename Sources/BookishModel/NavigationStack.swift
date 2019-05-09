// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let navigationStackChannel = Logger("com.elegantchaos.bookish.model.NavigationStack")

public class NavigationStack<ItemType> {
    internal var stack: [ItemType]
    internal var position: Int
    
    public var current: ItemType? {
        if stack.count == 0 {
            return nil
        } else {
            return stack[position - 1]
        }
    }

    public var canGoBack: Bool {
        return position > 1
    }
    
    public var canGoForward: Bool {
        return position < stack.count
    }
    
    public init() {
        stack = []
        position = 0
    }

    public func reset(to: ItemType? = nil) {
        stack = []
        position = 0
        if let item = to {
            push(item)
        }
    }
    
    public func push(_ item: ItemType) {
        navigationStackChannel.log("Adding item \(item). Current position \(position).")
        let count = stack.count - position
        stack.removeLast(count)
        stack.append(item)
        position = stack.count
        navigationStackChannel.log("New position \(position)")
    }
    
    @discardableResult public func goBack() -> ItemType? {
        guard position > 1 else {
            return nil
        }

        position -= 1
        return stack[position - 1]
    }

    @discardableResult public func goForward() -> ItemType? {
        guard position < stack.count else {
            return nil
        }
        
        position += 1
        return stack[position - 1]
    }
}
