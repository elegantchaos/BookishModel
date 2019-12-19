// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore
import Actions

/// Import monitor which intercepts the importerFinished callback in order to run the action completion.
/// All the monitor callbacks are also passed on to a real monitor (if there is one).
struct ActionImportMonitor: ImportDelegate {
    let wrappedMonitor: ImportDelegate?
    let actionCompletion: ModelAction.Completion
    
    init(context: ActionContext, completion: @escaping ModelAction.Completion) {
        self.wrappedMonitor = context[.monitorKey] as? ImportDelegate
        self.actionCompletion = completion
    }
    
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { wrappedMonitor?.importerNeedsFile(for: importer, completion: completion) }
    func importerWillStartSession(_ session: ImportSession, withCount count: Int) { wrappedMonitor?.importerWillStartSession(session, withCount: count) }
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { wrappedMonitor?.importerWillContinueSession(session, withItem: item, of: count) }
    func importerDidFinishWithStatus(_ status: ImportStatus) {
        wrappedMonitor?.importerDidFinishWithStatus(status)
        actionCompletion(.ok)
    }
}

extension ActionKey {
    public static let importerKey: ActionKey = "importer"
    public static let monitorKey: ActionKey = "importMonitor"
    public static let managerKey: ActionKey = "importManager"
    public static let urlKey: ActionKey = "url"

}
public class ImportAction: ModelAction {
    
    public class override func standardActions() -> [Action] {
        return [
            ImportAction(),
        ]
    }
    
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
        // the importer can be provided explicitly, or as an id (in which case the manager is also needed)
        var importer: Importer? = context[.importerKey] as? Importer
        if importer == nil, let manager = context[.managerKey] as? ImportManager, let importerID = context[.importerKey] as? String {
            importer = manager.importer(identifier: importerID)
        }

        // some importers need a url, some don't, so we handle both alternatives
        if let importer = importer {
            
            struct WrappedMonitor: ImportDelegate {
                let wrappedMonitor: ImportDelegate
                let actionCompletion: ModelAction.Completion
                
                func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { wrappedMonitor.importerNeedsFile(for: importer, completion: completion) }
                func importerWillStartSession(_ session: ImportSession, withCount count: Int) { wrappedMonitor.importerWillStartSession(session, withCount: count) }
                func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { wrappedMonitor.importerWillContinueSession(session, withItem: item, of: count) }
                func importerFinishedWithStatus(_ status: ImportStatus) {
                    wrappedMonitor.importerDidFinishWithStatus(status)
                    actionCompletion(.ok)
                }
            }
            
            let monitor = ActionImportMonitor(context: context, completion: completion)
            if let url = context.url(withKey: .urlKey) {
                importer.run(importing: url, in: collection, monitor: monitor)
            } else {
                importer.run(in: collection, monitor: monitor)
            }
        }
    }
}
