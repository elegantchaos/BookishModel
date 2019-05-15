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

    override func run(shell: Shell) throws -> Result {
        let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let jsonURL = rootURL.appendingPathComponent("Build Sample.json")

        StringLocalization.registerLocalizationBundle(Bundle.main)
        
        let xmlURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Sample.xml")
        let kindleURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Kindle.xml")
        let sampleURL = rootURL.appendingPathComponent("../BookishModel/Resources/Sample.sqlite")
        
        let model = BookishModel.model()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try? coordinator.destroyPersistentStore(at: sampleURL, ofType: NSSQLiteStoreType)
        
        self.container = CollectionContainer(name: "test", url: sampleURL) { (container, error) in
            var variables: [String:Any] = ProcessInfo.processInfo.environment
            variables["sampleURL"] = xmlURL
            variables["kindleURL"] = kindleURL
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
        
        return .running
    }
}
