// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore
import Actions

extension ActionContext { // TODO: move into Actions
    func url(withKey key: String) -> URL? {
        let value = info[key]
        if let url = value as? URL {
            return url
        } else if let string = value as? String {
            return URL(fileURLWithPath: string)
        }
        return nil
    }
}

/// Import monitor which intercepts the importerFinished callback in order to run the action completion.
/// All the monitor callbacks are also passed on to a real monitor (if there is one).
struct ActionImportMonitor: ImportMonitor {
    let wrappedMonitor: ImportMonitor?
    let actionCompletion: ModelAction.Completion
    
    init(context: ActionContext, completion: @escaping ModelAction.Completion) {
        self.wrappedMonitor = context[ImportAction.monitorKey] as? ImportMonitor
        self.actionCompletion = completion
    }
    
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { wrappedMonitor?.importerNeedsFile(for: importer, completion: completion) }
    func importerWillStartSession(_ session: ImportSession, withCount count: Int) { wrappedMonitor?.importerWillStartSession(session, withCount: count) }
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { wrappedMonitor?.importerWillContinueSession(session, withItem: item, of: count) }
    func importerDidFinishWithStatus(_ status: ImportStatus) {
        wrappedMonitor?.importerDidFinishWithStatus(status)
        actionCompletion()
    }
}

public class ImportAction: ModelAction {
    public static let importerKey = "importer"
    public static let monitorKey = "importMonitor"
    public static let managerKey = "importManager"
    public static let urlKey = "url"
    
    public class override func standardActions() -> [Action] {
        return [
            ImportAction(),
        ]
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        // the importer can be provided explicitly, or as an id (in which case the manager is also needed)
        var importer: Importer? = context[ImportAction.importerKey] as? Importer
        if importer == nil, let manager = context[ImportAction.managerKey] as? ImportManager, let importerID = context[ImportAction.importerKey] as? String {
            importer = manager.importer(identifier: importerID)
        }

        // some importers need a url, some don't, so we handle both alternatives
        if let importer = importer {
            
            struct WrappedMonitor: ImportMonitor {
                let wrappedMonitor: ImportMonitor
                let actionCompletion: ModelAction.Completion
                
                func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { wrappedMonitor.importerNeedsFile(for: importer, completion: completion) }
                func importerWillStartSession(_ session: ImportSession, withCount count: Int) { wrappedMonitor.importerWillStartSession(session, withCount: count) }
                func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { wrappedMonitor.importerWillContinueSession(session, withItem: item, of: count) }
                func importerFinishedWithStatus(_ status: ImportStatus) {
                    wrappedMonitor.importerDidFinishWithStatus(status)
                    actionCompletion()
                }
            }
            
            let monitor = ActionImportMonitor(context: context, completion: completion)
            if let url = context.url(withKey: ImportAction.urlKey) {
                importer.run(importing: url, in: store, monitor: monitor)
            } else {
                importer.run(in: store, monitor: monitor)
            }
        }
    }
}
