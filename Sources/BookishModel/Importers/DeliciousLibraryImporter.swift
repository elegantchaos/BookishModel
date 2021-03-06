// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData
import JSONDump
import Logger

let deliciousChannel = Logger("DeliciousImporter")

public class DeliciousLibraryImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.delicious-library" }

    public init(manager: ImportManager) {
        super.init(name: "Delicious Library", source: .userSpecifiedFile, manager: manager)
    }
    
    override func makeSession(importing url: URL, in context: NSManagedObjectContext, monitor: ImportMonitor?) -> URLImportSession? {
        return DeliciousLibraryImportSession(importer: self, context: context, url: url, monitor: monitor)
    }

    public override var fileTypes: [String]? {
        return ["xml"]
    }
}

class DeliciousLibraryImportSession: URLImportSession {
    typealias Record = [String:Any]
    typealias RecordList = [Record]
    
    var list: RecordList
    var cachedPeople: [String:Person] = [:]
    var cachedPublishers: [String:Publisher] = [:]
    var cachedSeries: [String:Series] = [:]
    let deliciousTag: Tag
    let importedTag: Tag

    let formatsToSkip = ["Audio CD", "Audio CD Enhanced", "Audio CD Import", "Video Game", "VHS Tape", "VideoGame", "DVD"]

    
    override init?(importer: Importer, context: NSManagedObjectContext, url: URL, monitor: ImportMonitor?) {
        // check we can parse the xml
        guard let data = try? Data(contentsOf: url), let list = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? RecordList else {
            return nil
        }

        // check that the records look to be in the right format
        guard let record = list.first, let _ = record["actorsCompositeString"] as? String else {
            return nil
        }

        self.deliciousTag = Tag.named("delicious-library", in: context)
        self.importedTag = Tag.named("imported", in: context)
        self.list = list
        super.init(importer: importer, context: context, url: url, monitor: monitor)
    }
    
    override func run() {
        monitor?.session(self, willImportItems: list.count)
        var item = 0
        for record in list {
            monitor?.session(self, willImportItem: item, of: list.count)
            DispatchQueue.main.sync {
                self.process(record: record)
            }
            item += 1
        }
        monitor?.sessionDidFinish(self)
    }
    
    private func process(record: Record) {
        let format = record["formatSingularString"] as? String
        let formatOK = format == nil || !formatsToSkip.contains(format!)
        let type = record["type"] as? String
        let typeOK = type == nil || !formatsToSkip.contains(type!)
        if formatOK && typeOK {
            if let title = record["title"] as? String, let creators = record["creatorsCompositeString"] as? String {
                let identifier: String
                if let uuid = record["uuidString"] as? String {
                    identifier = uuid
                } else if let uuid = record["foreignUUIDString"] as? String {
                    identifier = uuid
                } else {
                    identifier = "delicious-import-\(title)"
                }

                // we try to find a book with the same uuid
                // this is intended to ensure that if the same import runs multiple times,
                // we won't keep making new copies of the same books
                let book: Book
                if let existing = Book.withIdentifier(identifier, in: context) {
                    book = existing
                } else {
                    book = Book.named(title, in: context)
                    book.uuid = identifier
                    book.source = DeliciousLibraryImporter.identifier
                }

                deliciousTag.addToBooks(book)
                importedTag.addToBooks(book)
                
                book.name = title
                book.subtitle = record["subtitle"] as? String
                book.importDate = Date()

                if let ean = record["ean"] as? String, ean.isISBN13 {
                    book.isbn = ean
                } else if let isbn = record["isbn"] as? String {
                    let trimmed = isbn.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    book.isbn = trimmed.isbn10to13
                }
                
                if let height = record["boxHeightInInches"] as? Double, height > 0 {
                    book.height = height
                }

                if let width = record["boxWidthInInches"] as? Double, width > 0 {
                    book.width = width
                }

                if let length = record["boxLengthInInches"] as? Double, length > 0 {
                    book.length = length
                }

                book.asin = record["asin"] as? String
                book.classification = record["deweyDecimal"] as? String
                
                book.added = record["creationDate"] as? Date
                book.modified = record["lastModificationDate"] as? Date
                book.published = record["publishDate"] as? Date
                
                book.importRaw = record.jsonDump()
                
                book.format = format
                
                if let url = (record["coverImageLargeURLString"] as? String) ?? (record["coverImageMediumURLString"] as? String) ?? (record["coverImageSmallURLString"] as? String) {
                    book.imageURL = url
                }
                
                process(creators: creators, for: book)
                
                if let publishers = record["publishersCompositeString"] as? String, !publishers.isEmpty {
                    process(publishers: publishers, for: book)
                }
                
                if let series = record["seriesSingularString"] as? String, !series.isEmpty {
                    process(series: series, position: 0, for: book)
                }
            }
        }
    }

    private func process(creators: String, for book: Book) {
        var index = 1
        for creator in creators.split(separator: "\n") {
            let trimmed = creator.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let author: Person
                if let cached = cachedPeople[trimmed] {
                    author = cached
                } else {
                    author = Person.named(trimmed, in: context)
                    if author.source == nil {
                        author.source = DeliciousLibraryImporter.identifier
                        author.uuid = "\(book.uuid!)-author-\(index)"
                    }
                    index += 1
                    cachedPeople[trimmed] = author
                }
                let relationship = author.relationship(as: Role.StandardName.author)
                relationship.add(book)
            }
        }
    }
    
    private func process(publishers: String, for book: Book) {
        for publisher in publishers.split(separator: "\n") {
            let trimmed = publisher.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let publisher: Publisher
                if let cached = cachedPublishers[trimmed] {
                    publisher = cached
                } else {
                    publisher = Publisher.named(trimmed, in: context)
                    if publisher.source == nil {
                        publisher.source = DeliciousLibraryImporter.identifier
                    }
                    cachedPublishers[trimmed] = publisher
                }
                publisher.add(book)
            }
        }
    }
    
    private func process(series: String, position: Int, for book: Book) {
        let trimmed = series.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmed != "" {
            let series: Series
            if let cached = cachedSeries[trimmed] {
                series = cached
            } else {
                series = Series.named(trimmed, in: context)
                if series.source == nil {
                    series.source = DeliciousLibraryImporter.identifier
                }
                cachedSeries[trimmed] = series
            }
            let entry = SeriesEntry(context: context)
            entry.book = book
            entry.series = series
            if position != 0 {
                entry.position = Int16(position)
            }
        }
    }

}

