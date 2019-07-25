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
        actions.append(contentsOf: RoleAction.standardActions())
        actions.append(contentsOf: LookupAction.standardActions())
        actions.append(contentsOf: TagAction.standardActions())
        actions.append(ChangeValueAction())
        actions.append(ImportAction())
        actions.append(ScanSeriesAction())

        return actions
    }
    
    func nameKeys(context: ActionContext) -> (String, String) {
        let id = context.identifier
        return ("action.\(id).title", "action.\(id).short")
    }

    public func modelValidate(context: ActionContext) -> Bool {
        return (context[ActionContext.modelKey] as? NSManagedObjectContext) != nil
    }

    open override func validate(context: ActionContext) -> Action.Validation {
        let (nameKey, shortKey) = nameKeys(context: context)
        return Action.Validation(enabled: modelValidate(context: context), visible: true, name: nameKey.localized, shortName: shortKey.localized)
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
        let valid: Action.Validation = super.validate(context: context)
        guard valid.enabled && valid.visible else {
            return valid
        }

        var enabled = valid.enabled
        var name = valid.name
        var shortName = valid.shortName
        
        if let selection = context[ActionContext.selectionKey] as? [EntityType] {
            let count = selection.count
            enabled = count >= minimumToEnable
            if (count > 1) && usingPluralTitle {
                let (nameKey, shortKey) = nameKeys(context: context)
                name = "\(nameKey).plural".localized
                shortName = "\(shortKey).plural".localized
            }
        }
        
        return Action.Validation(enabled: enabled, visible: valid.visible, name: name, shortName: shortName)
    }

    override func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {
        perform(context: context, model: model)
        completion()
    }

    open func perform(context: ActionContext, model: NSManagedObjectContext) {
        
    }
}
