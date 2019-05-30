// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

public class ChangeValueAction: SyncModelAction {
    public static let valueKey = "value"
    public static let propertyKey = "property"

    /**
     Helper which sends the action.
     A single-object selection may be specified explicitly, or may be omitted, in which
     case it's expected to be supplied by the context.
     */
    
    public class func send(_ identifier: String, from sender: Any, manager: ActionManager, property: String, value: Any?, to: Any?) {
        let selection = to == nil ? nil : [to!]
        send(identifier, from: sender, manager: manager, property: property, value: value, selection: selection)
    }
    
    /**
     Helper which builds and sends the action.
     The selection may be specified explicitly, or may be omitted, in which
     case it's expected to be supplied by the context.
    */
    
    public class func send(_ identifier: String, from sender: Any, manager: ActionManager, property: String, value: Any?, selection: [Any]? = nil) {
        let info = ActionInfo(sender: sender)
        info[ChangeValueAction.propertyKey] = property
        info[ChangeValueAction.valueKey] = value
        if let selection = selection {
            info[ActionContext.selectionKey] = selection
        }
        manager.perform(identifier: identifier, info: info)
    }

    public override func validate(context: ActionContext) -> Bool {
        return
            (context[ActionContext.selectionKey] as? [NSManagedObject] != nil) &&
            (context[ChangeValueAction.propertyKey] as? String != nil) &&
                super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [NSManagedObject],
            let key = context[ChangeValueAction.propertyKey] as? String
        {
            let value = context[ChangeValueAction.valueKey]
            for item in selection {
                assert(item.managedObjectContext == model)
                let existingValue = item.value(forKey: key)
                let changed: Bool
                if value == nil && existingValue == nil {
                    changed = false
                } else if (value == nil) || (existingValue == nil) {
                    changed = true
                } else if let existingObject = existingValue as? NSObject, let object = value as? NSObject {
                    changed = !existingObject.isEqual(object)
                } else {
                    changed = true
                }
                if changed {
                    item.setValue(value, forKey: key)
                }
            }
        }
    }
}
