// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore
import Localization

public class StandardRolesImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.standard-roles" }
    
    public init(manager: ImportManager) {
        super.init(name: "Standard Roles", source: .knownLocation, manager: manager)
    }
    
    override func makeSession(in store: Datastore, monitor: ImportDelegate?) -> ImportSession? {
        return StandardRolesImportSession(importer: self, store: store, monitor: monitor)
    }
}

class StandardRolesImportSession: ImportSession {
    override func run() {
        // Add a few standard roles to the context
        let monitor = self.monitor
        let count = Role.StandardName.allCases.count
        monitor?.importerWillStartSession(self, withCount: count)
        var roles: [EntityReference] = []
        var item = 0
        for name in Role.StandardName.allCases {
            monitor?.importerWillContinueSession(self, withItem: item, of: count)
            let role = Entity.identifiedBy("standard-\(name)",
                createAs: .role,
                with: [
                    .name: name.rawValue,
                    .notes: "Role.standard.\(name).notes".localized,
                    .locked: true
                ]
            )
            roles.append(role)
            item += 1
        }

        store.get(entitiesWithIDs: roles) { _ in
            monitor?.importerDidFinishWithStatus(.succeeded(self))
        }
    }
}

