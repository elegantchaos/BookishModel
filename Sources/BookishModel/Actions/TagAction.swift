// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

public class TagAction: SyncModelAction {
    public static let addedTagsKey = "added"
    public static let removedTagsKey = "removed"

    open class override func standardActions() -> [Action] {
        return [
            ChangeTagsAction(),
            RenameTagAction(),
            DeleteTagAction(),
        ]
    }
}

public class ChangeTagsAction: TagAction {
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
            if
                let selection = context[ActionContext.selectionKey] as? [ModelObject],
                let addedTags = context[TagAction.addedTagsKey] as? Set<Tag>,
                let removedTags = context[TagAction.removedTagsKey] as? Set<Tag> {
                for tag in removedTags {
                    tag.remove(from: selection)
                }
                for tag in addedTags {
                    tag.add(to: selection)
                }

        }
    }
}

public class DeleteTagAction: TagAction {
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        print("delete tag")
        print(context)
    }
    
}

public class RenameTagAction: TagAction {
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        print("rename tag")
        print(context)
    }
}
