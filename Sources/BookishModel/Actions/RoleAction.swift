// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore
import Logger

let roleActionChannel = Channel("com.elegantchaos.bookish.model.RoleAction")

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol RoleViewer {
    func reveal(role: Role)
}


/**
 Objects that want to observe construction/destruction
 of roles should implement this protocol.
 */

public protocol RoleLifecycleObserver: ActionObserver {
    func created(role: Role)
    func deleted(role: Role)
}

/**
 Common functionality for all role-related actions.
 */

open class RoleAction: ModelAction {
    public static let roleKey = "role"
    
    open override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        
        if let selection = context[.selection] as? [Role] {
            info.enabled = info.enabled && selection.count > 0
        } else {
            info.enabled = false
        }
        
        return info
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewRoleAction(),
            DeleteRoleAction(),
            RevealRoleAction(),
        ]
    }
}

/**
 Action that creates a new role.
 */

class NewRoleAction: RoleAction {
    public override func validate(context: ActionContext) -> Validation {
        return modelValidate(context:context) // we don't need a selection, so we skip to ModelAction's validation
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion(.ok)
//        let role = Role(context: model)
//        context.info.forObservers { (observer: RoleLifecycleObserver) in
//            observer.created(role: role)
//        }
    }
}

/**
 Action that deletes a role.
 */

class DeleteRoleAction: RoleAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        
        // only valid if there are some unlocked items in the selection
        if info.state == .active, let selection = context[.selection] as? [Role] {
            if selection.allSatisfy({ return $0.locked }) {
                info.state = .inactive
            }
        }

        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let selection = context[.selection] as? [Role] {
            for role in selection {
                if !role.locked { // only delete the unlocked ones
                    context.info.forObservers { (observer: RoleLifecycleObserver) in
                        observer.deleted(role: role)
                    }
                    
//                    model.delete(role)
                }
            }
        }
    }
}

/**
 Action that reveals a role in the UI.
 The role to reveal can either be set as the roleKey, or extracted from a relationship set as the relationshipKey
 */

class RevealRoleAction: ModelAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[.roleKey] as? Role != nil) && (context[.root] as? RoleViewer != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let viewer = context[.root] as? RoleViewer {
            if let role = context[.roleKey] as? Role {
                viewer.reveal(role: role)
            }
        }
    }
}
