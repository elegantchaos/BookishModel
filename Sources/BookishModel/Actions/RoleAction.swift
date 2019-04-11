// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions
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

open class RoleAction: SyncModelAction {
    public static let roleKey = "role"
    
    open override func validate(context: ActionContext) -> Bool {
        guard super.validate(context: context) else {
            return false
        }
        
        guard let selection = context[ActionContext.selectionKey] as? [Role] else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewRoleAction(identifier: "NewRole"),
            DeleteRoleAction(identifier: "DeleteRole"),
            RevealRoleAction(identifier: "RevealRole"),
        ]
    }
}

/**
 Action that creates a new role.
 */

class NewRoleAction: RoleAction {
    public override func validate(context: ActionContext) -> Bool {
        return modelValidate(context:context) // we don't need a selection, so we skip to ModelAction's validation
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let role = Role(context: model)
        context.info.forObservers { (observer: RoleLifecycleObserver) in
            observer.created(role: role)
        }
    }
}

/**
 Action that deletes a role.
 */

class DeleteRoleAction: RoleAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Role] {
            for role in selection {
                context.info.forObservers { (observer: RoleLifecycleObserver) in
                    observer.deleted(role: role)
                }
                
                model.delete(role)
            }
        }
    }
}

/**
 Action that reveals a role in the UI.
 The role to reveal can either be set as the roleKey, or extracted from a relationship set as the relationshipKey
 */

class RevealRoleAction: RoleAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[RoleAction.roleKey] as? Role != nil) && (context[ActionContext.rootKey] as? RoleViewer != nil) && super.modelValidate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let viewer = context[ActionContext.rootKey] as? RoleViewer {
            if let role = context[RoleAction.roleKey] as? Role {
                viewer.reveal(role: role)
            }
        }
    }
}
