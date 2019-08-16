// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

public class ImportManager {
    private var importers: [String:Importer] = [:]
    private var sessions: [ImportSession] = []
    
    public var sortedImporters: [Importer] {
        let instances = importers.values
        return instances.sorted(by: { return $0.name < $1.name })
    }
    
    public init() {
        // TODO: build this dynamically - from plugins maybe?
        register([
            DeliciousLibraryImporter(manager: self),
            KindleImporter(manager: self),
        ])
    }
    
    public func register(_ importersToRegister: [Importer]) {
        for importer in importersToRegister {
            importers[type(of: importer).identifier] = importer
        }
    }
    
    public func importer(identifier: String) -> Importer? {
        return importers[identifier]
    }
    
    public func importFrom(_ url: URL, to context: NSManagedObjectContext, completion finalCompletion: @escaping ImportSession.Completion) {
        var importersToTry = sortedImporters

        func runNextImporter() {
            if let importer = importersToTry.first {
                importersToTry.remove(at: 0)

                let sessionCompletion: ImportSession.Completion = { session in
                    if let session = session {
                        // if the import succeeded, we run the final completion
                        finalCompletion(session)
                    } else {
                        // if the import failed, we try the next importer
                        runNextImporter()
                    }
                }

                if let session = importer.makeSession(importing: url, in: context, completion: sessionCompletion) {
                    // the importer is potentially valid for the input url, so run it
                    session.run()
                } else {
                    // the importer can't handle the url, so try the next one
                    runNextImporter()
                }
                    
            } else {
                finalCompletion(nil)
            }
        }
        
        runNextImporter()
    }
    
    func sessionWillBegin(_ session: ImportSession) {
        sessions.append(session)
    }
    
    func sessionDidFinish(_ session: ImportSession) {
        if let index = sessions.firstIndex(of: session) {
            sessions.remove(at: index)
        }
    }

}
