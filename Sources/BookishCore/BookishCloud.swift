// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Logger

let cloudChannel = Logger("BookishCloud")

public class BookishCloud {
    let container: CKContainer
    static let sharesID = CKRecord.ID(recordName: "shares")

    public init() {
        self.container = CKContainer(identifier: "iCloud.com.elegantchaos.Bookish.settings")
    }
    
    public func setup(name: String) {
        container.accountStatus { (status, error) in
            if let error = error {
                cloudChannel.log(error)
            } else {
                cloudChannel.log("Cloud status is: \(status.rawValue)")
                if status == CKAccountStatus.available {
                    self.setupShareList(name: name)
                }
            }
        }
    }
    
    private func setupShareList(name: String) {
        let database = container.privateCloudDatabase
        database.fetch(withRecordID: BookishCloud.sharesID) { (record, error) in
            if let error = error {
                cloudChannel.log(error)
                let record = CKRecord(recordType: "ShareList", recordID: BookishCloud.sharesID)
                record.setValue([name], forKey: "shares")
                self.save(record: record, action: "created")
            } else if let record = record, let shares = record.value(forKey: "shares") as? [String] {
                cloudChannel.log("loaded \(record)")
                if !shares.contains(name) {
                    var newShares = [name]
                    newShares.append(contentsOf: shares)
                    record.setValue(newShares, forKey: "shares")
                    self.save(record: record, action: "updated")
                }
            }
        }
    }
    
    private func createShareList(name: String) {
        let database = container.privateCloudDatabase
        let record = CKRecord(recordType: "ShareList", recordID: BookishCloud.sharesID)
        record.setValue([name], forKey: "shares")
        database.save(record, completionHandler: { (record, error) in
            if let error = error {
                cloudChannel.log(error)
            } else {
                cloudChannel.log("made record \(record!)")
            }
        })
    }

    private func save(record: CKRecord, action: String) {
        let database = container.privateCloudDatabase
        database.save(record, completionHandler: { (record, error) in
            if let error = error {
                cloudChannel.log(error)
            } else {
                cloudChannel.log("\(action) record \(record!)")
            }
        })
    }

}
