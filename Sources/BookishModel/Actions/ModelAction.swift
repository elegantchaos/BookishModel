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
        actions.append(ImportAction(identifier: "Import"))
        actions.append(ScanSeriesAction(identifier: "ScanSeries"))

        return actions
    }
    
    public func modelValidate(context: ActionContext) -> Bool {
        return (context[ActionContext.modelKey] as? NSManagedObjectContext) != nil
    }

    open override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context)
    }
    
    internal func finish(model: NSManagedObjectContext, completion: @escaping Completion) {
        do {
            try model.save()
        } catch {
            let nserror = error as NSError
            modelActionChannel.log("failed to save \(nserror)\n\(nserror.userInfo)")
        }
        
        completion()
    }
    
    open override func perform(context: ActionContext, completed: @escaping Completion) {
        if let model = context[ActionContext.modelKey] as? NSManagedObjectContext {
            modelActionChannel.debug("performing \(context.identifier)")
            model.perform {
                self.perform(context: context, model: model, completion: {
                    do {
                        try model.save()
                    } catch {
                        let nserror = error as NSError
                        modelActionChannel.log("failed to save \(nserror)\n\(nserror.userInfo)")
                    }
                    
                    completed()
                })
            }
        } else {
            modelActionChannel.debug("missing model for action")
        }
    }
    
    func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {
        completion()
    }
}

open class SyncModelAction: ModelAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {
        perform(context: context, model: model)
        completion()
    }

    open func perform(context: ActionContext, model: NSManagedObjectContext) {
        
    }
}
