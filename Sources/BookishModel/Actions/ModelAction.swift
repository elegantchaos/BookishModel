// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

open class ModelAction: Action {
    open override func validate(context: ActionContext) -> Bool {
        return (context[ActionContext.modelKey] as? NSManagedObjectContext) != nil
    }
    
    open override func perform(context: ActionContext, completed: @escaping Completion) {
        if let model = context[ActionContext.modelKey] as? NSManagedObjectContext {
            model.perform {
                self.perform(context: context, model: model)
                completed()
            }
        }
    }
    
    public func perform(context: ActionContext, model: NSManagedObjectContext) {
        
    }
}
