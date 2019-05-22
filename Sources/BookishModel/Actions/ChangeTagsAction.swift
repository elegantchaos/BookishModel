// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

public class ChangeTagsAction: SyncModelAction {
    public static let addedTagsKey = "added"
    public static let removedTagsKey = "removed"
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
            if
                let selection = context[ActionContext.selectionKey] as? [ModelObject],
                let addedTags = context[ChangeTagsAction.addedTagsKey] as? Set<Tag>,
                let removedTags = context[ChangeTagsAction.removedTagsKey] as? Set<Tag> {
                for tag in removedTags {
                    tag.remove(from: selection)
                }
                for tag in addedTags {
                    tag.add(to: selection)
                }

        }
    }
}
