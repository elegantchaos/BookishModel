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
            let monitor = context[ImportAction.monitorKey] as? ImportMonitor
            if let url = context.url(withKey: ImportAction.urlKey) {
                importer.run(importing: url, in: store, monitor: monitor)
            } else {
                importer.run(in: store, monitor: monitor)
            }
        }
    }
}
