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
import Datastore

struct Session {
    let container: CollectionContainer
    let actions: ActionList
}

class MakeCommand: Command {
    var sessions: [Session] = []
    var done: Int = 0
    
    override var description: Command.Description {
        return Description(
            name: "make",
            help: "Make a sample database",
            usage: ["<names>"],
            arguments: ["names": "Comma-separated list of names of the databases to make"]
        )
    }
    
    fileprivate func cleanup(container: CollectionContainer) {
        done += 1
        if sessions.count == done {
            DispatchQueue.main.async {
                shell.exit(result: .ok)
            }
        }
    }
    
    fileprivate func finish(shell: Shell, container: CollectionContainer) {
        let types: [DatastoreType] = [.book, .series, .person, .publisher, .role, .tag]
        
        container.store.count(entitiesOfTypes: types) { counts in
            let bookCount = counts[0]
            let seriesCount = counts[1]
            let personCount = counts[2]
            let publisherCount = counts[3]
            let roleCount = counts[4]
            let tagCount = counts[5]
            print("\(bookCount) books, \(personCount) people, \(publisherCount) publishers, \(seriesCount) series, \(roleCount) roles, \(tagCount) tags.")
            
            container.store.save() { _ in
                
                container.store.encodeJSON() { json in
                    self.copyToDocument(from: container.store.url)
                    let jsonURL = container.store.url.deletingPathExtension().appendingPathExtension("json")
                    try? json.write(to: jsonURL, atomically: true, encoding: .utf8)
                    DispatchQueue.main.async {
                        self.cleanup(container: container)
                    }
                }
            }
        }
    }
    
    fileprivate func copyToDocument(from url: URL) {
        let fm = FileManager.default
        
        let documentURL = url.deletingPathExtension().appendingPathExtension("store")
        let contentURL = documentURL.appendingPathComponent("StoreContent")
        try? fm.createDirectory(at: contentURL, withIntermediateDirectories: true, attributes: nil)
        let suffixes = ["", "-shm", "-wal"]
        let source = url.lastPathComponent
        let root = url.deletingLastPathComponent()
        for suffix in suffixes {
            let from = root.appendingPathComponent("\(source)\(suffix)")
            let to = contentURL.appendingPathComponent("persistentStore\(suffix)")
            try? fm.copyItem(at: from, to: to)
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

        DatastoreContainer.destroy(storeAt: outputURL, removeFiles: true)
        
        CollectionContainer.load(name: name, url: outputURL, container: CollectionContainer.self, indexed: false) { result in
            switch result {
                case .failure(let error):
                    shell.log("Couldn't make collection \(name) at \(outputURL): \(error)")
                
                case .success(let loaded):
                    let container = loaded as! CollectionContainer
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
                    actions.addTask(Task(name: "finish \(name)", callback: { self.finish(shell: shell, container: container) }))
                    self.sessions.append(Session(container: container, actions: actions))
                    DispatchQueue.global(qos: .userInitiated).async {
                        actions.run()
                    }

            }
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
