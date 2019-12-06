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

public protocol ImportDelegate {
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void)
    func importerWillStartSession(_ session: ImportSession, withCount count: Int)
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int)
    func importerDidFinishWithStatus(_ status: ImportStatus)
}

public extension ImportDelegate {
    func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { }
    func importerWillStartSession(_ session: ImportSession, withCount count: Int) { }
    func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { }
    func importerDidFinishWithStatus(_ status: ImportStatus) { }
}

public class BlockImportDelegate: ImportDelegate {
    var chooseFileBlock: ((Importer, (URL) -> Void) -> Void)? = nil
    var willImportBlock: ((ImportSession, Int) -> Void)? = nil
    var willImportItemBlock: ((ImportSession, Int, Int) -> Void)? = nil
    var didFinishBlock: ((ImportStatus) -> Void)? = nil
    
    public func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) { chooseFileBlock?(importer, completion) }
    public func importerWillStartSession(_ session: ImportSession, withCount count: Int) { willImportBlock?(session, count) }
    public func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) { willImportItemBlock?(session, item, count) }
    public func importerDidFinishWithStatus(_ status: ImportStatus) { didFinishBlock?(status) }
}

public class WrapperImportDelegate: BlockImportDelegate {
    let wrappedMonitor: ImportDelegate?
    
    init(wrapping monitor: ImportDelegate) {
        self.wrappedMonitor = monitor
    }
    
    public override func importerNeedsFile(for importer: Importer, completion: @escaping (URL) -> Void) {
        wrappedMonitor?.importerNeedsFile(for: importer, completion: completion)
        super.importerNeedsFile(for: importer, completion: completion)
    }
    
    public override func importerWillStartSession(_ session: ImportSession, withCount count: Int) {
        wrappedMonitor?.importerWillStartSession(session, withCount: count)
        super.importerWillStartSession(session, withCount: count)
    }
    
    public override func importerWillContinueSession(_ session: ImportSession, withItem item: Int, of count: Int) {
        wrappedMonitor?.importerWillContinueSession(session, withItem: item, of: count)
        super.importerWillContinueSession(session, withItem: item, of: count)
    }
    
    public override func importerDidFinishWithStatus(_ status: ImportStatus) {
        wrappedMonitor?.importerDidFinishWithStatus(status)
        super.importerDidFinishWithStatus(status)
    }
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
            StandardRolesImporter(manager: self),
            TestDataImporter(manager: self)
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
    
    public func importFrom(_ url: URL, to store: Datastore, monitor: ImportDelegate) {
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
