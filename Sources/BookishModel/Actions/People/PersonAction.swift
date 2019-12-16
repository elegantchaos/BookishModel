// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions
import Logger

let personActionChannel = Channel("com.elegantchaos.bookish.model.PersonAction")
let bktChannel = Channel("com.elegantchaos.bookish.model.BktOutput")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol PersonViewer {
    func reveal(person: Person)
}


/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol PersonLifecycleObserver: ActionObserver {
    func created(person: Person)
    func deleted(person: Person)
}

extension ActionKey {
    public static let personKey: ActionKey = "person"
    public static let relationshipKey: ActionKey = "relationship"
    public static let role: ActionKey = "role"
    public static let splitNameKey: ActionKey = "splitName"
    public static let splitUUIDKey: ActionKey = "splitUUID"
}

/**
 Common functionality for all person-related actions.
 */

open class PersonAction: ModelAction {
    
    open class override func standardActions() -> [Action] {
        return [
            NewPersonAction(),
            DeletePersonAction(),
            RevealPersonAction(),
            MergePersonAction(),
            SplitPersonAction()
        ]
    }
}
