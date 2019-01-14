// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions
import Logger

let modelActionChannel = Logger("ModelAction")

open class ModelAction: Action {
    open class func standardActions() -> [Action] {
        var actions = [Action]()
        actions.append(contentsOf: BookAction.standardActions())
        actions.append(contentsOf: PersonAction.standardActions())
        actions.append(contentsOf: PublisherAction.standardActions())
        actions.append(contentsOf: SeriesAction.standardActions())
        actions.append(ChangeValueAction(identifier: "ChangeValue"))
        return actions
    }
    
    public func modelValidate(context: ActionContext) -> Bool {
        return (context[ActionContext.modelKey] as? NSManagedObjectContext) != nil
    }

    open override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context)
    }
    
    open override func perform(context: ActionContext, completed: @escaping Completion) {
        if let model = context[ActionContext.modelKey] as? NSManagedObjectContext {
            modelActionChannel.debug("performing \(context.identifier)")
            model.perform {
                self.perform(context: context, model: model)
                
                do {
                    try model.save()
                } catch {
                    let nserror = error as NSError
                    modelActionChannel.log("failed to save \(nserror)\n\(nserror.userInfo)")
                }
                
                completed()
            }
        } else {
            modelActionChannel.debug("missing model for action")
        }
    }
    
    open func perform(context: ActionContext, model: NSManagedObjectContext) {
        
    }
    
}
