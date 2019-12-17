

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that removes a relationship from a book.
 */

class RemoveRelationshipAction: EntityAction {
    class RemoveRelationshipArguments: EntityAction.Arguments {
        let role: String
        let person: EntityReference
        
        override init?(from context: ActionContext) {
            guard
                let role = context[.role] as? String,
                let person = context[.person] as? EntityReference else {
                    return nil
            }
            
            self.role = role
            self.person = person
            super.init(from: context)
        }
    }
    
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (RemoveRelationshipArguments(from: context) != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        guard let arguments = RemoveRelationshipArguments(from: context) else {
            completion(.failure(Error.missingArguments))
            return
        }
        
        let key = PropertyDictionary.keyForRole(PropertyType(arguments.role), for: arguments.person)
        store.remove(properties: [key], of: arguments.selection) {
            completion(.ok)
        }
    }
}
