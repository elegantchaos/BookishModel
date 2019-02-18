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

BookishModel.registerLocalizations()

let url = URL(fileURLWithPath: "test.sql")
let model = BookishModel.model()
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
try! coordinator.destroyPersistentStore(at: url, ofType: "binary")

let container = CollectionContainer(name: "test", url: url) { (container, error) in
    let context = container.managedObjectContext
    container.save()
    
    let manager = ActionManager()
    manager.register(ModelAction.standardActions())
    
    let info = ActionInfo()
    info.registerNotification(notification: { (stage, actionContext) in
        if stage == .didPerform {
            print(context.countEntities(type: Book.self))
            print("done")
            exit(0)
        }
    })

    info[ActionContext.modelKey] = context
    manager.perform(identifier: "NewBook", info: info)
}


dispatchMain()

