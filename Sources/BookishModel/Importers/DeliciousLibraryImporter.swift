// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import Foundation
import JSONDump
import Logger

let deliciousChannel = Logger("DeliciousImporter")

public class DeliciousLibraryImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.delicious-library" }

    public init(manager: ImportManager) {
        super.init(name: "Delicious Library", source: .userSpecifiedFile, manager: manager)
    }
    
    override func makeSession(importing url: URL, in store: Datastore, monitor: ImportDelegate?) -> URLImportSession? {
        return DeliciousLibraryImportSession(importer: self, store: store, url: url, monitor: monitor)
    }

    public override var fileTypes: [String]? {
        return ["xml"]
    }
}

class DeliciousLibraryImportSession: URLImportSession {
    typealias Record = [String:Any]
    typealias RecordList = [Record]
    typealias Index = [String:Record]
    
    var list: RecordList
    var cachedPeople: [String:Person] = [:]
    var cachedPublishers: [String:Publisher] = [:]
    var cachedSeries: [String:Series] = [:]
    let deliciousTag: EntityReference
    let includeRaw = true
    
    let formatsToSkip = ["Audio CD", "Audio CD Enhanced", "Audio CD Import", "Video Game", "VHS Tape", "VideoGame", "DVD"]

    
    override init?(importer: Importer, store: Datastore, url: URL, monitor: ImportDelegate?) {
        // check we can parse the xml
        guard let data = try? Data(contentsOf: url), let list = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? RecordList else {
            return nil
        }

        // check that the records look to be in the right format
        guard let record = list.first, let _ = record["actorsCompositeString"] as? String else {
            return nil
        }

        self.deliciousTag = Entity.identifiedBy("tag-delicious-library", initialiser: EntityInitialiser(as: .tag, properties: [.name: "delicious-library"]))
        self.list = list
        super.init(importer: importer, store: store, url: url, monitor: monitor)
    }
    
    override func run() {
        let store = self.store
        let monitor = self.monitor
        monitor?.importerWillStartSession(self, withCount: list.count)

        var item = 0
        var properties: [EntityReference: PropertyDictionary] = [:]
        for record in list {
            if let identifier = identifier(for: record) {
                let book = Entity.identifiedBy(identifier, createAs: .book)
                monitor?.importerWillContinueSession(self, withItem: item, of: list.count)
                addProperties(for: book, identifier: identifier, from: record, into: &properties)
            }
            item += 1
        }

        store.add(properties: properties) {
            monitor?.importerDidFinishWithStatus(.succeeded(self))
        }
    }
    
    func identifier(for record: Record) -> String? {
        let format = record["formatSingularString"] as? String
        let formatOK = format == nil || !formatsToSkip.contains(format!)
        let type = record["type"] as? String
        let typeOK = type == nil || !formatsToSkip.contains(type!)
        if formatOK && typeOK {
            if let title = record["title"] as? String {
                let identifier: String
                if let uuid = record["uuidString"] as? String {
                    identifier = uuid
                } else if let uuid = record["foreignUUIDString"] as? String {
                    identifier = uuid
                } else {
                    identifier = "delicious-import-\(title)"
                }

                return identifier
            }
        }
        
        return nil
    }
    
    func addProperties(for book: EntityReference, identifier bookID: String, from data: Record, into properties: inout [EntityReference: PropertyDictionary]) {
        var bookProperties = PropertyDictionary()
        bookProperties.extract(from: data, stringsWithMapping: [
            "title": .name,
            "subtitle": .subtitle,
            "asin": .asin,
            "deweyDecimal": .classification,
            "formatSingularString": .format
        ])
        
        bookProperties[.source] = DeliciousLibraryImporter.identifier
        bookProperties[.importDate] = Date()
        bookProperties.addTag(deliciousTag)
        bookProperties.addTag(importedTag)

        if let ean = data["ean"] as? String, ean.isISBN13 {
            bookProperties[.isbn] = ean
        } else if let isbn = data["isbn"] as? String {
            let trimmed = isbn.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            bookProperties[.isbn] = trimmed.isbn10to13
        }
        
        bookProperties.extract(from: data, stringsWithMapping: [
            "boxHeightInInches": .height,
            "boxWidthInInches": .width,
            "boxLengthInInches": .length
            ]
        )

        bookProperties.extract(from: data, datesWithMapping: [
            "creationDate": .added,
            "lastModificationDate": .importedModificationDate,
            "publishDate": .published
        ])
        
        if includeRaw {
            bookProperties[.importRaw] = data.jsonDump()
        }
        
        bookProperties.extract(stringWithKeyIn: ["coverImageLargeURLString", "coverImageMediumURLString", "coverImageSmallURLString"], from: data, intoKey: .imageURL)
        
        if let creators = data["creatorsCompositeString"] as? String {
            addProperties(for: bookID, creators: creators, into: &bookProperties)
        }
        
        if let publishers = data["publishersCompositeString"] as? String, !publishers.isEmpty {
            addProperties(for: bookID, publishers: publishers, into: &bookProperties)
        }
        
        if let series = data["seriesSingularString"] as? String, !series.isEmpty {
            addProperties(for: book, series: series, position: 0, into: &properties)
        }

        properties[book] = bookProperties
    }


    private func addProperties(for bookID: String, creators: String, into properties: inout PropertyDictionary) {
        var index = 1
        for creator in creators.split(separator: "\n") {
            let trimmed = creator.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let identifier = "\(bookID)-author-\(index)"
                let initialProperties = EntityInitialiser(
                    as: .person,
                    properties: [.source: DeliciousLibraryImporter.identifier],
                    identifier: identifier
                )
                let author = Entity.named(trimmed, initialiser: initialProperties)
                properties.addRole(PropertyType.author, for: author)
                index += 1
            }
        }
    }
    
    private func addProperties(for bookID: String, publishers: String, into properties: inout PropertyDictionary) {
        for publisher in publishers.split(separator: "\n") {
            let trimmed = publisher.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let initialiser = EntityInitialiser(as: .publisher, properties: [.source: DeliciousLibraryImporter.identifier])
                let publisher = Entity.named(trimmed, initialiser: initialiser)
                properties.addPublisher(publisher)
            }
        }
    }
    
    private func addProperties(for book: EntityReference, series: String, position: Int, into properties: inout [EntityReference: PropertyDictionary]) {
        let trimmed = series.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmed != "" {
            let initialiser = EntityInitialiser(as: .series, properties: [.source: DeliciousLibraryImporter.identifier])
            let series = Entity.named(trimmed, initialiser: initialiser)
            let seriesProperties = PropertyDictionary([PropertyKey("entry-\(position)") : book])
            properties[series] = seriesProperties
        }
    }

}

