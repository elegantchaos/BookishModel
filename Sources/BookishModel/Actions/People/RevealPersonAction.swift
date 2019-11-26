// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that reveals a person in the UI.
 The person to reveal can either be set as the personKey, or extracted from a relationship set as the relationshipKey
 */

class RevealPersonAction: PersonAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled &&
            ((context[PersonAction.relationshipKey] as? Relationship != nil) || (context[PersonAction.personKey] as? Person != nil)) &&
            (context[ActionContext.rootKey] as? PersonViewer != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let viewer = context[ActionContext.rootKey] as? PersonViewer {
            if let person = context[PersonAction.personKey] as? Person {
                viewer.reveal(person: person)
            } else if let role = context[PersonAction.relationshipKey] as? Relationship, let person = role.person {
                viewer.reveal(person: person)
            }
        }
    }
}
