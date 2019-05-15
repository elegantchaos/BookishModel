// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions
import BookishModel
import CoreData
import CommandShell

struct ActionSpec: Decodable {
    let name: String
    let action: String
    let people: [String]?
    let books: [String]?
    let params: [String:String]?
}

struct ActionFile: Decodable {
    let actions: [ActionSpec]
}

class BookishTool {
    let container: CollectionContainer
    let context: NSManagedObjectContext
    let taskList: TaskList
    let actionManager = ActionManager()
    let importManager = ImportManager()
    var variables: [String:Any] = ProcessInfo.processInfo.environment
    let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    
    init() {
        StringLocalization.registerLocalizationBundle(Bundle.main)
        
        let xmlURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Sample.xml")
        let kindleURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Kindle.xml")
        let sampleURL = rootURL.appendingPathComponent("../BookishModel/Resources/Sample.sqlite")
        
        let taskList = TaskList()
        let model = BookishModel.model()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try? coordinator.destroyPersistentStore(at: sampleURL, ofType: NSSQLiteStoreType)
        
        self.container = CollectionContainer(name: "test", url: sampleURL) { (container, error) in
            taskList.nextTask()
        }
        self.context = container.managedObjectContext
        self.taskList = taskList
        
        actionManager.register(ModelAction.standardActions())
        
        variables["sampleURL"] = xmlURL
        variables["kindleURL"] = kindleURL
        for n in 0 ..< CommandLine.arguments.count {
            variables["\(n)"] = CommandLine.arguments[n]
        }
        
    }
    
    fileprivate func makeActionTasks(_ actions: ActionFile) {
        for action in actions.actions {
            var expandedParams: [String:Any] = [:]
            if let params = action.params {
                for (key, value) in params {
                    let start = value.startIndex
                    if let index = value.firstIndex(of: "$"), index == start {
                        
                        let variable = String(value[value.index(after: index)...])
                        expandedParams[key] = variables[variable]
                    } else {
                        expandedParams[key] = value
                    }
                }
            }
            
            taskList.addTask(Task(name: action.name, callback: {
                self.perform(action: action, with: expandedParams)
            }))
        }
    }
    
    func loadActions() {
        let jsonURL = rootURL.appendingPathComponent("Build Sample.json")
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        do {
            let actions = try decoder.decode(ActionFile.self, from: jsonData)
            makeActionTasks(actions)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.detailedDescription(for: jsonData))
            
        } catch {
            print(error)
        }
    }
    
    func perform(action: ActionSpec, with params: [String:Any] = [:]) {
        let info = ActionInfo()
        info.registerNotification { (stage, actionContext) in
            if stage == .didPerform {
                if let report = actionContext["report"] as? String {
                    print(report)
                }
                self.taskList.nextTask()
            }
        }
        
        info[ActionContext.modelKey] = context
        info[ImportAction.managerKey] = importManager
        for (key, value) in params {
            info[key] = value
        }
        
        if let people = action.people {
            var selection: [ModelObject] = []
            for personID in people {
                let request: NSFetchRequest<Person> = Person.fetcher(in: context)
                request.predicate = NSPredicate(format: "uuid = \"\(personID)\"")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                let results = try? context.fetch(request)
                if let found = results, let person = found.first {
                    selection.append(person)
                }
            }
            info[ActionContext.selectionKey] = selection
        } else if let books = action.books {
            var selection: [ModelObject] = []
            for bookID in books {
                let request: NSFetchRequest<Book> = Book.fetcher(in: context)
                request.predicate = NSPredicate(format: "uuid = \"\(bookID)\"")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                let results = try? context.fetch(request)
                if let found = results, let book = found.first {
                    selection.append(book)
                }
            }
            info[ActionContext.selectionKey] = selection
        }
        
        actionManager.perform(identifier: action.action, info: info)
    }
    
    func finish() {
        let bookCount = context.countEntities(type: Book.self)
        let seriesCount = context.countEntities(type: Series.self)
        print("\(bookCount) books, in \(seriesCount) series.")
        print("done")
        exit(0)
    }
    
    func run() {
        taskList.addTask(Task(name: "finish", callback: { self.finish() }))
        taskList.run()
    }
}

class BookishToolCommand: Command {
    
    override var description: Command.Description {
        return Description(name: "make", help: "Make a sample database", usage: ["<name>"])
    }

    override func run(shell: Shell) throws -> Result {
        let tool = BookishTool()
        tool.loadActions()
        tool.run()
        
        return .running
    }
}
