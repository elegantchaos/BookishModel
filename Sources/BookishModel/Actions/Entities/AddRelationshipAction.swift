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
    
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
        guard let arguments = AddRelationshipArguments(from: context) else {
            completion(.failure(Error.missingArguments))
            return
        }

        let person = Person()
        let role = PropertyType(arguments.role)
        var updates: [Book] = []
        for item in arguments.selection {
            if let book = item as? Book {
                book.addRole(role, for: person)
                updates.append(book)
            }
        }
        
        collection.store.add(properties: updates) {
            completion(.ok)
        }
    }
}
