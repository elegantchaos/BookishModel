// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class ImportManager {
    private var importers: [String:Importer] = [:]
    private var sessions: [ImportSession] = []
    
    public var sortedImporters: [Importer] {
        return importers.sorted(by: { return $0.value.name < $1.value.name }).map({ $0.value })
    }
    
    public init() {
        // TODO: build this dynamically - from plugins maybe?
        register([
            DeliciousLibraryImporter(manager: self),
            KindleImporter(manager: self)
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
    
    func sessionWillBegin(_ session: ImportSession) {
        sessions.append(session)
    }
    
    func sessionDidFinish(_ session: ImportSession) {
        if let index = sessions.firstIndex(of: session) {
            sessions.remove(at: index)
        }
    }

}
