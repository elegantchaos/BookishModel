// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions
import Logger

let modelActionChannel = Logger("ModelAction")

open class ModelAction: Action {
    public static let entityTypeKey = "entityType"
    
    open class func standardActions() -> [Action] {
        var actions = [Action]()
        actions.append(contentsOf: BookAction.standardActions())
        actions.append(contentsOf: PersonAction.standardActions())
        actions.append(contentsOf: PublisherAction.standardActions())
        actions.append(contentsOf: SeriesAction.standardActions())
        actions.append(contentsOf: RoleAction.standardActions())
        actions.append(contentsOf: LookupAction.standardActions())
        actions.append(contentsOf: TagAction.standardActions())
        actions.append(ChangeValueAction())
        actions.append(ImportAction())
        actions.append(ScanSeriesAction())

        return actions
    }
 
    public func modelValidate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && ((context[ActionContext.modelKey] as? NSManagedObjectContext) != nil)
        return info
    }

    open override func validate(context: ActionContext) -> Validation {
        return modelValidate(context: context)
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
    open func validateSelection<EntityType>(type: EntityType.Type, context: ActionContext, minimumToEnable: Int = 1, usingPluralTitle: Bool) -> Action.Validation {
        var info = super.validate(context: context)

        if info.enabled,
            let indexType = context[ModelAction.entityTypeKey] as? EntityType.Type,
            let selection = context[ActionContext.selectionKey] as? [EntityType],
            indexType == type {
            let count = selection.count
            info.enabled = count >= minimumToEnable
            if (count > 1) && usingPluralTitle {
                info.fullName = "\(info.fullName).plural"
                info.shortName = "\(info.shortName).plural"
            }
        } else {
            info.state = .ineligable
        }
        
        return info
    }

    override func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {
        perform(context: context, model: model)
        completion()
    }

    open func perform(context: ActionContext, model: NSManagedObjectContext) {
        
    }
}
