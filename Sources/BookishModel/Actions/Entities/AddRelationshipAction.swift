// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Foundation

/**
 Action that adds a relationship between a book and a newly created person.
 */

class AddRelationshipAction: EntityAction {
    class AddRelationshipArguments: EntityAction.Arguments {
        let role: String
        
        override init?(from context: ActionContext) {
            guard let role = context[.role] as? String else {
                return nil
            }
            
            self.role = role
            super.init(from: context)
        }
    }

    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (AddRelationshipArguments(from: context) != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        guard let arguments = AddRelationshipArguments(from: context) else {
            completion(.failure(Error.missingArguments))
            return
        }

        let person = Entity.createAs(.person)
        var roleProperty = PropertyDictionary()
        roleProperty.addRole(PropertyType(arguments.role), for: person)

        var properties: [EntityReference:PropertyDictionary] = [:]
        for item in arguments.selection {
            properties[item] = roleProperty
        }
        
        store.add(properties: properties) {
            completion(.ok)
        }
    }
}
