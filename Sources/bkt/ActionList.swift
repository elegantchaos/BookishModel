// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions
import BookishModel
import CoreData
import Expressions



struct OldActionSpec: Decodable {
    let name: String
    let action: String
    let people: [String]?
    let books: [String]?
    let params: [String:String]?
}

struct OldActionFile: Decodable {
    let actions: [OldActionSpec]
}

struct ActionItemSpec: Codable {
    let time: Double
    let action: ActionSpec
}

struct ActionSpec: Codable {
    let action: String
    let info: [String:AnyCodable]
}

struct ActionFile: Codable {
    let actions: [ActionItemSpec]
}

struct Variable: Constructable {
    var name = ""
}

class ActionList: TaskList {
    let container: CollectionContainer
    let actionManager: ActionManager
    let importManager: ImportManager
    
    let variablePattern = try! NSRegularExpression(pattern: ".*\\$(\\w+).*")
    
    init(container: CollectionContainer, actionManager: ActionManager, importManager: ImportManager) {
        self.container = container
        self.actionManager = actionManager
        self.importManager = importManager
    }
    
    fileprivate func makeActionTasks(_ actions: ActionFile, variables: [String:Any]) {
        
        for action in actions.actions {
            var expandedParams: [String:Any] = [:]
            let params = action.action.info
            for (key, value) in params {
                if let string = value.value as? String, let match = variablePattern.firstMatch(in: string, capturing: [\Variable.name: 1]), let variable = variables[match.name] as? String {
                    let expanded = string.replacingOccurrences(of: "$\(match.name)", with: variable)
                    expandedParams[key] = expanded
                } else if let array = value.value as? [AnyCodable] {
                    expandedParams[key] = array.map { $0.value }
                } else if let dictionary = value.value as? [String:AnyCodable] {
                    expandedParams[key] = dictionary.mapValues { $0.value }
                } else {
                    expandedParams[key] = value.value
                }
            }
            
            let actionID = action.action.action
            addTask(Task(name: actionID, callback: {
                self.perform(action: actionID, with: expandedParams)
            }))
        }
    }
    
    func load(from jsonURL: URL, variables: [String:Any]) {
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        do {
            let actions = try decoder.decode(ActionFile.self, from: jsonData)
            makeActionTasks(actions, variables: variables)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.detailedDescription(for: jsonData))
            
        } catch {
            print(error)
        }
    }
    
    fileprivate func perform(action: String, with params: [String:Any] = [:]) {
        let info = ActionInfo()
        info.registerNotification { (stage, actionContext) in
            if stage == .didPerform {
                if let report = actionContext["report"] as? String {
                    print(report)
                }
                self.nextTask()
            }
        }
        
        let context = container.managedObjectContext
        info[ActionContext.modelKey] = context
        info[ImportAction.managerKey] = importManager
        for (key, value) in params {
            info[key] = value
        }
        
        if let selectionIDs = params["selectionIds"] as? [String] {
            var selection: [ModelObject] = []
            for personID in selectionIDs {
                let request: NSFetchRequest<Person> = Person.fetcher(in: context)
                request.predicate = NSPredicate(format: "uuid = \"\(personID)\"")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                let results = try? context.fetch(request)
                if let found = results, let person = found.first {
                    selection.append(person)
                }
            }
            for bookID in selectionIDs {
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
        
        actionManager.perform(identifier: action, info: info)
    }
}
