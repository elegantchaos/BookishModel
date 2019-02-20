// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class ImportManager {
    private var importers: [String:Importer] = [:]
    private var sessions: [ImportSession] = []
    
    public var sortedImporters: [Importer] {
        return importers.sorted(by: { return $0.key < $1.key }).map({ $0.value })
    }
    
    public init() {
        // TODO: build this dynamically
        register(importer: DeliciousLibraryImporter(manager: self))
    }
    
    public func register(importer: Importer) {
        importers[importer.name] = importer
    }
    
    public func importer(named: String) -> Importer? {
        return importers[named]
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
