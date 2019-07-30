// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions
import BookishModel
import CoreData
import CommandShell
import Localization

struct Session {
    let container: CollectionContainer
    let actions: ActionList
}

class MakeCommand: Command {
    var sessions: [Session] = []
    
    deinit {
        print("blah")
    }
    
    override var description: Command.Description {
        return Description(
            name: "make",
            help: "Make a sample database",
            usage: ["<names>"],
            arguments: ["names": "Comma-separated list of names of the databases to make"]
        )
    }

    fileprivate func cleanup(container: CollectionContainer) {
        if let index = sessions.firstIndex(where: { $0.container === container }) {
            sessions.remove(at: index)
            if sessions.count == 0 {
                shell.exit(result: .ok)
            }
        }
    }
    
    fileprivate func finish(shell: Shell, container: CollectionContainer) {
        let context = container.managedObjectContext
        let bookCount = context.countEntities(type: Book.self)
        let seriesCount = context.countEntities(type: Series.self)
        let personCount = context.countEntities(type: Person.self)
        let publisherCount = context.countEntities(type: Publisher.self)
        let roleCount = context.countEntities(type: Role.self)
        let tagCount = context.countEntities(type: Tag.self)
        print("\(bookCount) books, \(personCount) people, \(publisherCount) publishers, \(seriesCount) series, \(roleCount) roles, \(tagCount) tags.")
        
        DispatchQueue.main.async {
            self.cleanup(container: container)
        }
    }

    fileprivate func make(name: String, shell: Shell) {
        shell.log("Making collection '\(name)'.")

        let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let jsonURL = rootURL.appendingPathComponent("Build \(name).json")
        
        Localization.registerLocalizationBundle(Bundle.main)
        
        let resourceURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/")
        let outputDirectory = rootURL.appendingPathComponent("../BookishModel/Resources/").appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        let outputURL = outputDirectory.appendingPathComponent("\(name).sqlite")
        
        let model = BookishModel.model()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.destroyPersistentStore(at: outputURL, ofType: NSSQLiteStoreType)
        } catch {
            shell.log("Couldn't delete old file: \(error)")
        }
        
        let container = CollectionContainer(name: name, url: outputURL) { (container, error) in
            var variables: [String:Any] = ProcessInfo.processInfo.environment
            variables["resourceURL"] = resourceURL.path
            for n in 0 ..< CommandLine.arguments.count {
                variables["\(n)"] = CommandLine.arguments[n]
            }
            
            let actionManager = ActionManager()
            actionManager.register(ModelAction.standardActions())
            
            let importManager = ImportManager()
            importManager.register([
                StandardRolesImporter(manager: importManager),
                TestDataImporter(manager: importManager)
            ])

            let actions = ActionList(container: container, actionManager: actionManager, importManager: importManager)
            actions.load(from: jsonURL, variables: variables)
            actions.addTask(Task(name: "finish", callback: { self.finish(shell: shell, container: container) }))
            actions.run()
            self.sessions.append(Session(container: container, actions: actions))
        }
    }
    
    override func run(shell: Shell) throws -> Result {
        let names = shell.arguments.argument("names").split(separator: ",")
        for name in names {
            make(name: String(name), shell: shell)
        }
        return .running
    }
}
