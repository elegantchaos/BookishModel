// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions
import BookishModel
import CoreData
import CommandShell

class MakeCommand: Command {
    var container: CollectionContainer? = nil
    var actions: ActionList? = nil
    
    override var description: Command.Description {
        return Description(name: "make", help: "Make a sample database", usage: ["<name>"])
    }

    fileprivate func finish(shell: Shell) {
        guard let context = container?.managedObjectContext else {
            shell.exit(result: .runFailed)
        }

        let bookCount = context.countEntities(type: Book.self)
        let seriesCount = context.countEntities(type: Series.self)
        print("\(bookCount) books, in \(seriesCount) series.")
        shell.exit(result: .ok)
    }

    fileprivate func make(name: String, shell: Shell) {
        shell.log("Making collection '\(name)'.")

        let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let jsonURL = rootURL.appendingPathComponent("Build \(name).json")
        
        StringLocalization.registerLocalizationBundle(Bundle.main)
        
        let resourceURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/")
        let outputURL = rootURL.appendingPathComponent("../BookishModel/Resources/\(name).sqlite")
        
        let model = BookishModel.model()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try? coordinator.destroyPersistentStore(at: outputURL, ofType: NSSQLiteStoreType)
        
        self.container = CollectionContainer(name: name, url: outputURL) { (container, error) in
            var variables: [String:Any] = ProcessInfo.processInfo.environment
            variables["resourceURL"] = resourceURL.path
            for n in 0 ..< CommandLine.arguments.count {
                variables["\(n)"] = CommandLine.arguments[n]
            }
            
            let actionManager = ActionManager()
            actionManager.register(ModelAction.standardActions())
            
            let importManager = ImportManager()
            
            let actions = ActionList(container: container, actionManager: actionManager, importManager: importManager)
            actions.load(from: jsonURL, variables: variables)
            actions.addTask(Task(name: "finish", callback: { self.finish(shell: shell) }))
            actions.run()
            self.actions = actions
        }
    }
    override func run(shell: Shell) throws -> Result {
        let name = shell.arguments.argument("name")
        make(name: name, shell: shell)
        return .running
    }
}
