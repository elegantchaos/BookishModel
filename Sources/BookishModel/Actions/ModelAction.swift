// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Foundation
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
        actions.append(contentsOf: ImportAction.standardActions())
        actions.append(ChangeValueAction())
        actions.append(ScanSeriesAction())

        return actions
    }
 
    public func modelValidate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && ((context[ActionContext.modelKey] as? Datastore) != nil)
        return info
    }

    open override func validate(context: ActionContext) -> Validation {
        return modelValidate(context: context)
    }

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

    open override func perform(context: ActionContext, completed: @escaping Completion) {
        if let collection = context[ActionContext.modelKey] as? CollectionContainer {
            modelActionChannel.debug("performing \(context.identifier)")
            let store = collection.store
            perform(context: context, store: store) {
                store.save() { result in
                    switch result {
                    case .failure(let error as NSError):
                        modelActionChannel.log("failed to save \(error)\n\(error.userInfo)")
                    default:
                        break
                    }
                    completed()
                }
            }
                            
        }
    }
    
    func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion()
    }
}
