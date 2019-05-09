// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let navigationStackChannel = Logger("com.elegantchaos.bookish.model.NavigationStack")

public class NavigationStack<ItemType>: CustomStringConvertible {
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
        navigationStackChannel.log("Resetting.")
        stack = []
        position = 0
        if let item = to {
            push(item)
        }
        navigationStackChannel.log("Stack is now:\n\(self)")
    }
    
    public func push(_ item: ItemType) {
        navigationStackChannel.log("Adding item \(item) at \(position).")
        let count = stack.count - position
        stack.removeLast(count)
        stack.append(item)
        position = stack.count
        navigationStackChannel.log("Stack is now:\n\(self)")
    }
    
    @discardableResult public func goBack() -> ItemType? {
        guard position > 1 else {
            navigationStackChannel.log("Can't go back.")
            return nil
        }

        navigationStackChannel.log("Going back.")
        position -= 1
        navigationStackChannel.log("Stack is now:\n\(self)")
        return stack[position - 1]
    }

    @discardableResult public func goForward() -> ItemType? {
        guard position < stack.count else {
            navigationStackChannel.log("Can't go forward.")
            return nil
        }
        
        navigationStackChannel.log("Going forward.")
        position += 1
        navigationStackChannel.log("Stack is now:\n\(self)")
        return stack[position - 1]
    }
    
    public var description: String {
        var string = ""
        let selected = position - 1
        for n in 0 ..< stack.count {
            string += n == selected ? "--> " : "    "
            string += "\(stack[n])\n"
        }
        return string
    }
}
