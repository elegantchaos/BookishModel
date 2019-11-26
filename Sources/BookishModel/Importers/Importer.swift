// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore

public class Importer {
    public enum Source {
        case knownLocation
        case userSpecifiedFile
    }
    
    public let name: String
    public let source: Source
    public let manager: ImportManager
    public class var identifier: String { return "import" }

    public init(name: String, source: Source, manager: ImportManager) {
        self.name = name
        self.source = source
        self.manager = manager
    }
    
    public var canImport: Bool {
        switch source {
        case .knownLocation:
            if let url = defaultImportLocation {
                return FileManager.default.fileExists(atPath: url.path)
            } else {
                return true
            }
            
        case .userSpecifiedFile:
            return true
        }
    }
    
    public func canImport(from url: URL) -> Bool {
        guard FileManager.default.fileExists(at: url) else {
            return false
        }

        guard let allowedTypes = fileTypes, allowedTypes.contains(url.pathExtension) else {
            return false
        }
        
        return true
    }
    
    public var defaultImportLocation: URL? {
        return nil
    }
    
    public var fileTypes: [String]? {
        return nil
    }
    
    public var panelPrompt: String {
        let identifier = type(of:self).identifier
        var string = "\(identifier).prompt".localized
        if string == "\(identifier).prompt" {
            string = "importer.prompt".localized
        }
        return string
    }

    public var panelMessage: String {
        let identifier = type(of:self).identifier
        var string = "\(identifier).message".localized
        if string == "\(identifier).message" {
            string = "importer.message".localized
        }
        return string
    }

    internal func makeSession(in store: Datastore, monitor: ImportMonitor?) -> ImportSession? {
        let session = ImportSession(importer: self, store: store, monitor: monitor)
        return session
    }

    internal func makeSession(importing url: URL, in store: Datastore, monitor: ImportMonitor?) -> URLImportSession? {
        let session = URLImportSession(importer: self, store: store, url: url, monitor: monitor)
        return session
    }
    
    public func run(importing url: URL, in store: Datastore, monitor: ImportMonitor? = nil) {
        if let session = makeSession(importing: url, in: store, monitor: monitor) {
            session.performImport()
        } else {
            monitor?.noImporter()
        }
    }

    public func run(in store: Datastore, monitor: ImportMonitor?) {
        switch source {
        case .knownLocation:
            if let session = makeSession(in: store, monitor: monitor) {
                session.performImport()
            } else {
                monitor?.noImporter()
            }
            
        case .userSpecifiedFile:
            monitor?.chooseFile(for: self, completion: { url in
                if let session = self.makeSession(importing: url, in: store, monitor: monitor) {
                    session.performImport()
                } else {
                    monitor?.noImporter()
                }
            })
        }
    }

}
