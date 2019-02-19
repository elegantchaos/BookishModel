// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData
import Actions

public class ImportAction: ModelAction {
    public static let importerKey = "importer"
    public static let managerKey = "importManager"
    public static let urlKey = "url"
    
    override func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {
        
        guard let manager = context[ImportAction.managerKey] as? ImportManager,
            let importerName = context[ImportAction.importerKey] as? String,
            let importer = manager.importer(named: importerName),
            let url = context[ImportAction.urlKey] as? URL else {
                completion()
                return
        }
        
        importer.run(importing: url, into: model) {
            completion()
        }
        
    }
}
