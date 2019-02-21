//
//  main.swift
//  bkt
//
//  Created by Sam Deane on 18/02/2019.
//  Copyright © 2019 Elegant Chaos Limited. All rights reserved.
//

import BookishModel
import Foundation
import Actions
import CoreData

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

struct Task {
    typealias Callback = () -> Void
    
    let name: String
    let callback: Callback
}

class TaskList {
    var tasks: [Task] = []
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func nextTask() {
        if !tasks.isEmpty {
            let task = tasks.removeFirst()
            print("task: \(task.name)")
            DispatchQueue.main.async {
                task.callback()
            }
        }
    }
    
    func run() {
        nextTask()
    }
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
        let xmlURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Sample.xml")
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
        for n in 0 ..< CommandLine.arguments.count {
            variables["\(n)"] = CommandLine.arguments[n]
        }

    }
    
    func loadActions() {
        let jsonURL = rootURL.appendingPathComponent("Build Sample.json")
        let decoder = JSONDecoder()
        let actions = try! decoder.decode(ActionFile.self, from: Data(contentsOf: jsonURL))
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
    
    func perform(action: ActionSpec, with params: [String:Any] = [:]) {
        let info = ActionInfo()
        info.registerNotification { (stage, actionContext) in
            if stage == .didPerform {
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
                if let found = results, let person = found.first as? Person {
                    selection.append(person)
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


BookishModel.registerLocalizations()

let tool = BookishTool()
tool.loadActions()
tool.run()

dispatchMain()

