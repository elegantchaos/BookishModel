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
    
    func importFromDelicious() {
        let manager = ImportManager()
        let importer = DeliciousLibraryImporter(manager: manager)
        let xmlURL = URL(fileURLWithPath: "/Users/sam/Projects/Bookish/Dependencies/BookishModel/Tests/BookishModelTests/Resources/Sample.xml")
        importer.run(importing: xmlURL, into: context) {
            self.taskList.nextTask()
        }
    }
    
    func perform(action: String) {
        let info = ActionInfo()
        info.registerNotification { (stage, actionContext) in
            if stage == .didPerform {
                self.taskList.nextTask()
            }
        }
        
        info[ActionContext.modelKey] = context
        actionManager.perform(identifier: action, info: info)
    }
    
    func finish() {
        print(context.countEntities(type: Book.self))
        print("done")
        exit(0)
    }
}

BookishModel.registerLocalizations()

let url = URL(fileURLWithPath: "test.sql")
let model = BookishModel.model()
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
try! coordinator.destroyPersistentStore(at: url, ofType: "binary")

let tool = BookishTool()
let tasks = tool.taskList

tasks.addTask(Task(name: "import", callback: { tool.importFromDelicious() }))
tasks.addTask(Task(name: "action", callback: { tool.perform(action: "NewBook") }))
tasks.addTask(Task(name: "finish", callback: { tool.finish() }))

tasks.run()


dispatchMain()

