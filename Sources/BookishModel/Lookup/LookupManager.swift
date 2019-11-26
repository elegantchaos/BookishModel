// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Datastore
import Logger

let lookupChannel = Channel("com.elegantchaos.bookish.model.Lookup")

public class LookupManager {

    let workerQueue: DispatchQueue
    let lockQueue: DispatchQueue
    let callbackQueue: DispatchQueue
    
    var services: [LookupService] = []
    
    public init(callbackQueue: DispatchQueue = DispatchQueue.main) {
        self.callbackQueue = callbackQueue
        self.workerQueue = DispatchQueue(label: "com.elegantchaos.bookish.model.lookup", qos: .userInitiated, attributes: .concurrent)
        self.lockQueue = DispatchQueue(label: "com.elegantchaos.bookish.model.lookup.result", qos: .userInitiated)
    }
    
    public func register(service: LookupService) {
        lookupChannel.log("Registered \(service.name)")
        services.append(service)
    }
    
    public func lookup(query: String, in store: Datastore, callback: @escaping LookupSession.Callback) -> LookupSession {
        lookupChannel.log("Looking up \(query)")
        let session = LookupSession(search: query, manager: self, in: store, callback: callback)
        session.run()
        return session
    }
}
