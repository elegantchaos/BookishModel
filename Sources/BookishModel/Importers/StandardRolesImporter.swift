// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

public class StandardRolesImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.standard-roles" }
    
    public init(manager: ImportManager) {
        super.init(name: "Standard Roles", source: .knownLocation, manager: manager)
    }
    
    override func makeSession(in context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) -> ImportSession {
        return StandardRolesImportSession(importer: self, context: context, completion: completion)
    }
}

class StandardRolesImportSession: ImportSession {
    override func run() {
        // Add a few standard roles to the context
        for name in Role.StandardName.allCases {
            let role = Role.named(name, in: context)
            role.notes = "Role.standard.\(name).notes".localized
            role.uuid = "standard-\(name)"
            role.locked = true
        }
    }
}

