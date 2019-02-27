// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
        services.append(service)
    }
    
    public func lookup(ean: String, callback: @escaping LookupSession.Callback) -> LookupSession {
        let session = LookupSession(search: ean, manager: self, callback: callback)
        session.run()
        return session
    }
}
