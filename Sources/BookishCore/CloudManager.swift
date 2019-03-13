// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Logger

let cloudChannel = Logger("CloudManager")

public class CloudManager {
    public let collectionIdentifier = "iCloud.com.elegantchaos.Bookish"
    let collectionContainer: CKContainer

//    public let settingsIdentifier = "iCloud.com.elegantchaos.Bookish.settings"
//    let settingsContainer: CKContainer

    public let journalIdentifier = "iCloud.com.elegantchaos.Bookish.journal"
    let journalContainer: CKContainer

    static let sharesID = CKRecord.ID(recordName: "shares")
    static let journalID = CKRecord.ID(recordName: "journal")
    
    public init() {
        collectionContainer = CKContainer(identifier: collectionIdentifier)
//        settingsContainer = CKContainer(identifier: settingsIdentifier)
        journalContainer = CKContainer(identifier: journalIdentifier)
    }
    
    public func setup(name: String) {
        journalContainer.accountStatus { (status, error) in
            if let error = error {
                cloudChannel.log(error)
            } else {
                cloudChannel.log("Cloud status is: \(status.rawValue)")
                if status == CKAccountStatus.available {
                    self.setupJournal()
                }
            }
        }
    }
    
    private func setupJournal() {
        
    }
    
    public func addJournalEntry(_ entry: [String:Any]) {
        let id = String(describing: Date.timeIntervalSinceReferenceDate)
        let record = CKRecord(recordType: "JournalEntry", recordID: CKRecord.ID(recordName: id))
        if let data = try? JSONSerialization.data(withJSONObject: entry, options: []), let json = String(data: data, encoding: .utf8) {
            record.setValue(json, forKey: "value")
            save(container: journalContainer, record: record, action: "Added journal entry")
        }
    }
    
    public func allJournalEntries() -> [[String:Any]] {
        let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
        journalContainer.privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
            }

            records?.forEach({ (record) in
                let recordName_fromProperty = record.recordID.recordName
                print("Journal entry, recordName: \(recordName_fromProperty)")
                let json = record.value(forKey: "value") as? String ?? ""
                print(json)
            })
        }
        
        return []
    }
    
//    private func setupShareList(name: String) {
//        let database = settingsContainer.privateCloudDatabase
//        database.fetch(withRecordID: CloudManager.sharesID) { (record, error) in
//            if let error = error {
//                cloudChannel.log(error)
//                let record = CKRecord(recordType: "ShareList", recordID: CloudManager.sharesID)
//                record.setValue([name], forKey: "shares")
//                self.save(record: record, action: "created")
//            } else if let record = record, let shares = record.value(forKey: "shares") as? [String] {
//                cloudChannel.log("loaded \(record)")
//                if !shares.contains(name) {
//                    var newShares = [name]
//                    newShares.append(contentsOf: shares)
//                    record.setValue(newShares, forKey: "shares")
//                    self.save(record: record, action: "updated")
//                }
//            }
//        }
//    }
//
//    private func createShareList(name: String) {
//        let database = settingsContainer.privateCloudDatabase
//        let record = CKRecord(recordType: "ShareList", recordID: CloudManager.sharesID)
//        record.setValue([name], forKey: "shares")
//        database.save(record, completionHandler: { (record, error) in
//            if let error = error {
//                cloudChannel.log(error)
//            } else {
//                cloudChannel.log("made record \(record!)")
//            }
//        })
//    }

    private func save(container: CKContainer, record: CKRecord, action: String) {
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
