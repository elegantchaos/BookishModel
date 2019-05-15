// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
