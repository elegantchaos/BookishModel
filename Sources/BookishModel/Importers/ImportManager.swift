// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore

public enum ImportStatus {
    case noImporter
    case succeeded(ImportSession)
    case failed(ImportSession)
}

public protocol ImportMonitor {
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void)
    func importerWillStartSession(_ session: ImportSession, withCount: Int)
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int)
    func importerDidFinishWithStatus(_ status: ImportStatus)
}

public extension ImportMonitor {
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { }
    func importerWillStartSession(_ session: ImportSession, withCount: Int) { }
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { }
    func importerDidFinishWithStatus(_ status: ImportStatus) { }
}

public struct BlockImportMonitor {
    let chooseFileBlock: ((Importer, (URL) -> Void) -> Void)? = nil
    let willImportBlock: ((ImportSession, Int) -> Void)? = nil
    let willImportItemBlock: ((ImportSession, Int, Int) -> Void)? = nil
    let didFinishBlock: ((ImportStatus) -> Void)? = nil
    
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { chooseFileBlock?(importer, completion) }
    func importerWillStartSession(_ session: ImportSession, willImportItems count: Int) { willImportBlock?(session, count) }
    func importerWillContinueSession(_ session: ImportSession, willImportItem item: Int, of count: Int) { willImportItemBlock?(session, item, count) }
    func importerFinishedWithStatus(status: ImportStatus) { didFinishBlock?(status) }
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
    
    public func importFrom(_ url: URL, to store: Datastore, monitor: ImportMonitor) {
        for importer in sortedImporters {
            if let session = importer.makeSession(importing: url, in: store, monitor: monitor) {
                session.performImport()
                break
            }
        }
        
        monitor.importerDidFinishWithStatus(.noImporter)
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
