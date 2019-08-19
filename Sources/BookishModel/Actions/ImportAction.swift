// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData
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
    public static let importerChooserKey = "importerChooser"
    public static let managerKey = "importManager"
    public static let urlKey = "url"
    
    public class override func standardActions() -> [Action] {
        return [
            ImportAction(),
            ChooseImportAction()
        ]
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext, completion: @escaping ModelAction.Completion) {

        var importer: Importer? = context[ImportAction.importerKey] as? Importer
        if importer == nil, let manager = context[ImportAction.managerKey] as? ImportManager, let importerID = context[ImportAction.importerKey] as? String {
            importer = manager.importer(identifier: importerID)
        }

        if let importer = importer {
            let count = model.countEntities(type: Book.self)

            let importCompletion: ImportSession.Completion =  { session in
                let added = model.countEntities(type: Book.self) - count
                context["report"] = "Imported \(added) books."
                completion()
            }
            
            if importer.source == .knownLocation {
                importer.run(in: model, completion: importCompletion)
            } else {
                guard let url = context.url(withKey: ImportAction.urlKey) else {
                    completion()
                    return
                }
                
                importer.run(importing: url, in: model, completion: importCompletion)
            }
        } else {
            completion()
        }
    }
}


public protocol ImporterChooser {
    func presentImporter(identifier: String)
}

class ChooseImportAction: Action {

    override func perform(context: ActionContext) {
        if let importerID = context[ImportAction.importerKey] as? String, let presenter = context[ImportAction.importerChooserKey] as? ImporterChooser {
            presenter.presentImporter(identifier: importerID)
        }
    }
}
