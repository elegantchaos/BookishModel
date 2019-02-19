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

    init() {
        let taskList = TaskList()
        let url = URL(fileURLWithPath: "test.sql")
        let model = BookishModel.model()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.destroyPersistentStore(at: url, ofType: "binary")
        
        self.container = CollectionContainer(name: "test", url: url) { (container, error) in
            taskList.nextTask()
        }
        self.context = container.managedObjectContext
        self.taskList = taskList

        actionManager.register(ModelAction.standardActions())
    }
    
    func perform(action: String, with params: [String:Any] = [:]) {
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
        actionManager.perform(identifier: action, info: info)
    }
    
    func finish() {
        let bookCount = context.countEntities(type: Book.self)
        let seriesCount = context.countEntities(type: Series.self)
        print("\(bookCount) books, in \(seriesCount) series.")
        print("done")
        exit(0)
    }
}

struct ActionSpec: Decodable {
    let name: String
    let action: String
    let params: [String:String]?
}

struct ActionFile: Decodable {
    let actions: [ActionSpec]
}

BookishModel.registerLocalizations()

let url = URL(fileURLWithPath: "test.sql")
let model = BookishModel.model()
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
try! coordinator.destroyPersistentStore(at: url, ofType: "binary")

let tool = BookishTool()
let tasks = tool.taskList

let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
let jsonURL = rootURL.appendingPathComponent("Build Sample.json")
let decoder = JSONDecoder()
let actions = try! decoder.decode(ActionFile.self, from: Data(contentsOf: jsonURL))

let xmlURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/Sample.xml")
let variables = ["sampleURL" : xmlURL]

for action in actions.actions {
    tasks.addTask(Task(name: action.name, callback: {
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
        
        tool.perform(action: action.action, with: expandedParams)
    }))
}

tasks.addTask(Task(name: "finish", callback: { tool.finish() }))
tasks.run()


dispatchMain()

