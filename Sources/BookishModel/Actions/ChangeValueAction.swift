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
     Helper which sends the action for a given object.
     */
    
    public class func send(_ identifier: String, from sender: Any, manager: ActionManager, property: String, value: Any, to: Any?) {
        if let object = to {
            send(identifier, from: sender, manager: manager, property: property, value: value, selection: [object])
        }
    }
    
    /**
     Helper which sends the action for a group of objects.
    */
    
    public class func send(_ identifier: String, from sender: Any, manager: ActionManager, property: String, value: Any, selection: [Any]) {
        let info = ActionInfo(sender: sender)
        info[ChangeValueAction.propertyKey] = property
        info[ChangeValueAction.valueKey] = value
        info[ActionContext.selectionKey] = selection
        manager.perform(identifier: identifier, info: info)
    }

    public override func validate(context: ActionContext) -> Bool {
        return
            (context[ActionContext.selectionKey] as? [NSManagedObject] != nil) &&
            (context[ChangeValueAction.propertyKey] as? String != nil) &&
            (context[ChangeValueAction.valueKey] != nil) &&
                super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [NSManagedObject],
            let key = context[ChangeValueAction.propertyKey] as? String,
            let value = context[ChangeValueAction.valueKey]
        {
            for item in selection {
                item.setValue(value, forKey: key)
            }
        }
        
        try! model.save()
    }
}
