// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class LookupManager {

    public let workerQueue: DispatchQueue
    public let resultQueue: DispatchQueue

    var services: [LookupService] = []
    
    public init() {
        workerQueue = DispatchQueue(label: "com.elegantchaos.bookish.model.lookup.worker", qos: .background)
        resultQueue = DispatchQueue(label: "com.elegantchaos.bookish.model.lookup.result", qos: .userInitiated, target: DispatchQueue.main)
    }
    
    public func register(service: LookupService) {
        services.append(service)
    }
    
    public func lookup(ean: String, callback: @escaping LookupSession.Callback) {
        let session = LookupSession(search: ean, manager: self, callback: callback)
        session.run()
    }
}
