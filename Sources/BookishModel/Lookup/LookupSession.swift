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
    
    public typealias Callback = (LookupSession, State) -> Void
    
    public let search: String
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
            callback(self, .starting)
            
            if services.count > 0 {
                for service in services {
                    self.running.insert(service)
                    workerQueue.async {
                        service.lookup(search: search, session: self)
                    }
                }
            } else {
                callback(self, .done)
            }
        }
    }
    
    public func add(candidate: LookupCandidate) {
        manager.resultQueue.async {
            self.callback(self, .foundCandidate(candidate))
        }
    }
    
    public func done(service: LookupService) {
        manager.resultQueue.async {
            if let _ = self.running.remove(service) {
                if self.running.count == 0 {
                    self.callback(self, .done)
                }
            }
        }
    }

    public func failed(service: LookupService) {
        manager.resultQueue.async {
            let running = self.running
            if let _ = self.running.remove(service) {
                self.callback(self, .failed(service))
                if running.count == 0 {
                    self.callback(self, .done)
                }
            }
        }
    }
    
}

