// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class LookupSession {
    public enum State {
        case starting
        case foundCandidate(LookupCandidate)
        case failed(LookupService)
        case done
    }
    
    public typealias Callback = (State) -> Void
    
    let search: String
    let manager: LookupManager
    let callback: Callback
    var running: Set<LookupService>
    
    init(search: String, manager: LookupManager, callback: @escaping Callback) {
        self.search = search
        self.manager = manager
        self.callback = callback
        self.running = Set<LookupService>()
    }
    
    func run() {
        let services = manager.services
        let callback = self.callback
        let search = self.search
        let workerQueue = manager.workerQueue
        
        manager.resultQueue.async {
            callback(.starting)
            
            if services.count > 0 {
                for service in services {
                    self.running.insert(service)
                    workerQueue.async {
                        service.lookup(search: search, session: self)
                    }
                }
            } else {
                callback(.done)
            }
        }
    }
    
    public func add(candidate: LookupCandidate) {
        manager.resultQueue.async {
            self.callback(.foundCandidate(candidate))
        }
    }
    
    public func done(service: LookupService) {
        manager.resultQueue.async {
            let running = self.running
            if let _ = self.running.remove(service) {
                if running.count == 0 {
                    self.callback(.done)
                }
            }
        }
    }

    public func failed(service: LookupService) {
        manager.resultQueue.async {
            let running = self.running
            if let _ = self.running.remove(service) {
                self.callback(.failed(service))
                if running.count == 0 {
                    self.callback(.done)
                }
            }
        }
    }
    
}

