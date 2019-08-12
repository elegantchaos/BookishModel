// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Logger

let cloudChannel = Logger("com.elegantchaos.bookish.model.CloudManager")
let journalChannel = Channel("com.elegantchaos.bookish.model.Journal")

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
            journalChannel.log("""

               {
                    "time" : \(id)
                    "action" : \(json)
               },
            """
            )
            save(container: journalContainer, record: record, action: "Added journal entry")
        }
    }

    public func forAllJournalEntries(perform block: @escaping (CKRecord) -> Void, completion: @escaping () -> Void) {
        let database = journalContainer.privateCloudDatabase
        let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        func makeOperation() -> CKQueryOperation {
            let operation = CKQueryOperation(query: query)
            operation.recordFetchedBlock = block
            
            operation.queryCompletionBlock = { (cursor, error) in
                if let error = error {
                    print(error)
                } else if let cursor = cursor {
                    let continuation = makeOperation()
                    continuation.cursor = cursor
                    database.add(continuation)
                } else {
                    completion()
                }
            }
            
            return operation
        }
        
        let operation = makeOperation()
        database.add(operation)
    }

    public func forAllJournalEntries(perform block: @escaping ([(String,String)]) -> Void) {
        var results: [(String, String)] = []
        self.forAllJournalEntries(
            perform: { record in
            let recordName_fromProperty = record.recordID.recordName
            let json = record.value(forKey: "value") as? String ?? ""
            results.append((recordName_fromProperty, json))
            },
        completion: {
            block(results)
        }
        )
    }
    
    public func resetJournal() {
        let database = journalContainer.privateCloudDatabase
        var ids: [CKRecord.ID] = []
        self.forAllJournalEntries(
            perform: { record in ids.append(record.recordID) },
            completion: {
                for recordID in ids {
                    database.delete(withRecordID: recordID, completionHandler: { (_,_) in })
                }
            }
        )
    }

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
