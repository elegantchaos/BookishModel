// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Foundation
import Logger

let modelActionChannel = Logger("ModelAction")

extension ActionKey {
    public static let entityTypeKey:ActionKey = "entityType"
}

extension ActionContext {
    var collectionContainer: CollectionContainer? {
        return info[.model] as? CollectionContainer
    }
    
    var collectionStore: Datastore? {
        return collectionContainer?.store
    }
}

open class ModelAction: Action {
    public enum Error: LocalizedError, Swift.Error {
        case missingSelection
        
        public var errorDescription: String? {
            switch self {
            case .missingSelection:
                return "Selection missing"
            }
        }
    }

    open class func standardActions() -> [Action] {
        var actions = [Action]()
        actions.append(contentsOf: EntityAction.standardActions())
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
        info.enabled = info.enabled && (context.collectionContainer != nil)
        return info
    }

    open override func validate(context: ActionContext) -> Validation {
        return modelValidate(context: context)
    }

    open func validateSelection<EntityType>(type: EntityType.Type, context: ActionContext, minimumToEnable: Int = 1, usingPluralTitle: Bool) -> Action.Validation {
        var info = super.validate(context: context)

        if info.enabled,
            let indexType = context[.entityTypeKey] as? EntityType.Type,
            let selection = context[.selection] as? [EntityType],
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
        if let store = context.collectionStore {
            modelActionChannel.debug("performing \(context.identifier)")
            perform(context: context, store: store) { result in
                store.save() { result in
                    switch result {
                    case .failure(let error as NSError):
                        modelActionChannel.log("failed to save \(error)\n\(error.userInfo)")
                    default:
                        break
                    }
                    completed(result)
                }
            }
                            
        }
    }
    
    func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion(.ok)
    }
}
