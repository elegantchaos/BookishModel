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
    public enum Error: LocalizedError, Swift.Error {
        case missingRole
        
        public var errorDescription: String? {
            switch self {
            case .missingRole:
                return "Role not specified"
            }
        }
    }
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && ((context[.role] as? String) != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        guard let selection = context[.selection] as? [EntityReference] else {
            completion(.failure(Error.missingSelection))
            return
        }
        
        guard let role = context[.role] as? String else {
            completion(.failure(Error.missingRole))
            return
        }
        
        let person = Entity.createAs(.person)
        var roleProperty = PropertyDictionary()
        roleProperty.addRole(PropertyType(role), for: person)

        var properties: [EntityReference:PropertyDictionary] = [:]
        for item in selection {
            properties[item] = roleProperty
        }
        
        store.add(properties: properties) {
            completion(.ok)
        }
    }
}
