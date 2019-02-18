// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class ImportSession: Equatable {
    public static func == (lhs: ImportSession, rhs: ImportSession) -> Bool {
        return lhs === rhs
    }
    
    public typealias Completion = () -> Void
    
    let url: URL
    let importer: Importer
    let context: NSManagedObjectContext
    let completion: Completion
    
    init(importer: Importer, context: NSManagedObjectContext, url: URL, completion: @escaping Completion) {
        self.importer = importer
        self.context = context
        self.url = url
        self.completion = completion
    }
    
    func performImport() {
        importer.manager.sessionWillBegin(self)
        run()
        completion()
        importer.manager.sessionDidFinish(self)
    }

    internal func run() {
    }
}
