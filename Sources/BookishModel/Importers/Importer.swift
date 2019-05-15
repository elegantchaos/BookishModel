// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

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
        
        return false
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

    internal func makeSession(in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) -> ImportSession {
        let session = ImportSession(importer: self, context: context, completion: completion)
        return session
    }

    internal func makeSession(importing url: URL, in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) -> URLImportSession {
        let session = URLImportSession(importer: self, context: context, url: url, completion: completion)
        return session
    }
    
    public func run(importing url: URL, in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) {
        let session = makeSession(importing: url, in: context, completion: completion)
        session.performImport()
    }

    public func run(in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) {
        let session = makeSession(in: context, completion: completion)
        session.performImport()
    }

}
