// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

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

extension ActionKey {
    public static let addedTagsKey: ActionKey = "added"
    public static let removedTagsKey: ActionKey = "removed"
    public static let tagKey: ActionKey = "tag"
    public static let tagNameKey: ActionKey = "tagName"

}
public class TagAction: ModelAction {
    
    open class override func standardActions() -> [Action] {
        return [
            ChangeTagsAction(),
            RenameTagAction(),
            DeleteTagAction(),
        ]
    }
}

public class ChangeTagsAction: TagAction {
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//            if
//                let selection = context[.selection] as? [ModelObject],
//                let addedTags = context[.addedTagsKey] as? Set<Tag>,
//                let removedTags = context[.removedTagsKey] as? Set<Tag> {
//                for tag in removedTags {
//                    tag.remove(from: selection)
//                }
//
//                for tag in addedTags {
//                    tag.add(to: selection)
//                }
//
//                context.info.forObservers { (observer: TagObserver) in
//                    observer.changed(adding: addedTags, removing: removedTags)
//                }
//        }
    }
}

public class DeleteTagAction: TagAction {
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        if let tag = context[.tagKey] as? Tag {
//            model.delete(tag)
            
            context.info.forObservers { (observer: TagObserver) in
                observer.deleted(tags: [tag])
            }
        }
    }
    
}

public class RenameTagAction: TagAction {
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
//        if let tag = context[.tagKey] as? Tag, let name = context[.tagNameKey] as? String {
//            tag.name = name
//            
//            context.info.forObservers { (observer: TagObserver) in
//                observer.renamed(tags: [tag])
//            }
//        }
    }
}
