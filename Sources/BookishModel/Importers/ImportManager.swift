// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

public protocol ImportMonitor {
    func chooseFile(for importer: Importer, completion: @escaping (URL) -> Void)
    func session(_ session: ImportSession, willImportItems count: Int)
    func session(_ session: ImportSession, willImportItem item: Int, of count: Int)
    func sessionDidFinish(_ session: ImportSession)
    func sessionDidFail(_ session: ImportSession)
    func noImporter()
}

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
    
    public func importFrom(_ url: URL, to context: NSManagedObjectContext, monitor: ImportMonitor) {
        var importersToTry = sortedImporters

        func runNextImporter() {
            if let importer = importersToTry.first {
                importersToTry.remove(at: 0)

                if let session = importer.makeSession(importing: url, in: context, monitor: monitor) {
                    // the importer is potentially valid for the input url, so run it
                    session.run()
                } else {
                    // the importer can't handle the url, so try the next one
                    runNextImporter()
                }
                    
            } else {
                monitor.noImporter()
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
