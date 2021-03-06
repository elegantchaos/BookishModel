// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

public protocol TagObserver: ActionObserver {
    func deleted(tags: Set<Tag>)
    func renamed(tags: Set<Tag>)
    func changed(adding addedTags: Set<Tag>, removing removedTags: Set<Tag>)
}

public extension TagObserver {
    func deleted(tags: Set<Tag>) { }
    func renamed(tags: Set<Tag>) { }
    func changed(adding addedTags: Set<Tag>, removing removedTags: Set<Tag>) { }
}

public class TagAction: SyncModelAction {
    public static let addedTagsKey = "added"
    public static let removedTagsKey = "removed"
    public static let tagKey = "tag"
    public static let tagNameKey = "tagName"
    
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
                
                context.info.forObservers { (observer: TagObserver) in
                    observer.changed(adding: addedTags, removing: removedTags)
                }
        }
    }
}

public class DeleteTagAction: TagAction {
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let tag = context[TagAction.tagKey] as? Tag {
            model.delete(tag)
            
            context.info.forObservers { (observer: TagObserver) in
                observer.deleted(tags: [tag])
            }
        }
    }
    
}

public class RenameTagAction: TagAction {
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let tag = context[TagAction.tagKey] as? Tag, let name = context[TagAction.tagNameKey] as? String {
            tag.name = name
            
            context.info.forObservers { (observer: TagObserver) in
                observer.renamed(tags: [tag])
            }
        }
    }
}
