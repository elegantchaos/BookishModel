// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

public class ChangeValueAction: ModelAction {
    public static let valueKey = "value"
    public static let propertyKey = "property"

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
    }
}
