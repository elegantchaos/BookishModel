// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

extension ActionKey {
    public static let valueKey: ActionKey = "value"
    public static let propertyKey: ActionKey = "property"
}

public class ChangeValueAction: ModelAction {

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
        info[.propertyKey] = property
        info[.valueKey] = value
        if let selection = selection {
            info[.selection] = selection
        }
        manager.perform(identifier: identifier, info: info)
    }

    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
//        info.enabled = info.enabled &&
//            (context[.selection] as? [NSManagedObject] != nil) &&
//            (context[ChangeValueAction.propertyKey] as? String != nil)
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//        if
//            let selection = context[.selection] as? [NSManagedObject],
//            let key = context[ChangeValueAction.propertyKey] as? String
//        {
//            let value = context[ChangeValueAction.valueKey]
//            for item in selection {
//                assert(item.managedObjectContext == model)
//                let existingValue = item.value(forKey: key)
//                let changed: Bool
//                if value == nil && existingValue == nil {
//                    changed = false
//                } else if (value == nil) || (existingValue == nil) {
//                    changed = true
//                } else if let existingObject = existingValue as? NSObject, let object = value as? NSObject {
//                    changed = !existingObject.isEqual(object)
//                } else {
//                    changed = true
//                }
//                if changed {
//                    item.setValue(value, forKey: key)
//                }
//            }
//        }
    }
}
