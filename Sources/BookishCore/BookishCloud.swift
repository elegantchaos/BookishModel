// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Logger

let cloudChannel = Logger("BookishCloud")

public class BookishCloud {
    public let collectionIdentifier = "iCloud.com.elegantchaos.Bookish"
    let collectionContainer: CKContainer

    public let settingsIdentifier = "iCloud.com.elegantchaos.Bookish.settings"
    let settingsContainer: CKContainer

    static let sharesID = CKRecord.ID(recordName: "shares")

    public init() {
        collectionContainer = CKContainer(identifier: collectionIdentifier)
        settingsContainer = CKContainer(identifier: settingsIdentifier)
    }
    
    public func setup(name: String) {
        settingsContainer.accountStatus { (status, error) in
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
        let database = settingsContainer.privateCloudDatabase
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
        let database = settingsContainer.privateCloudDatabase
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
        let database = settingsContainer.privateCloudDatabase
        database.save(record, completionHandler: { (record, error) in
            if let error = error {
                cloudChannel.log(error)
            } else {
                cloudChannel.log("\(action) record \(record!)")
            }
        })
    }

}
