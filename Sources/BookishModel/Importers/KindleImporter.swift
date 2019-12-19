// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import Foundation
import JSONDump
import Logger

let kindleChannel = Logger("KindleImporter")

public class KindleImporter: Importer {
    override class public var identifier: String { return "com.elegantchaos.bookish.importer.kindle" }

    public init(manager: ImportManager) {
        super.init(name: "Kindle", source: .userSpecifiedFile, manager: manager)
    }
    
    override func makeSession(importing url: URL, in store: Datastore, monitor: ImportDelegate?) -> URLImportSession? {
        return KindleImportSession(importer: self, store: store, url: url, monitor: monitor)
    }
    
    public override var defaultImportLocation: URL? {
        if let library = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let cache = library.appendingPathComponent("Containers/com.amazon.Kindle/Data/Library/Application Support/Kindle/Cache/KindleSyncMetadataCache.xml")
            return cache
        }

        return nil
    }

    public override var fileTypes: [String]? {
        return ["xml"]
    }
}


struct KindleBook {
    let title: String
    let authors: [String]
    let publishers: [String]
    let asin: String
    let raw: [String:Any]
}

class KindleState: TagProcessorState {
    var books: [KindleBook] = []
    required init() {
    }
}

class DateHandler: TagHandler<KindleState> {
    static let formatter = ISO8601DateFormatter()
    var date: Date?
    
    override func processor(_ processor: TagProcessor<KindleState>, foundText text: String) {
        if let date = DateHandler.formatter.date(from: text) {
            self.date = date
        }
    }
        
    override func reduce(_ processor: TagProcessor<KindleState>) -> Any? {
        return date
    }
}

class StringHandler: TagHandler<KindleState> {
    var text = ""
    
    override func processor(_ processor: TagProcessor<KindleState>, foundText text: String) {
        self.text.append(text)
    }
    
    override func reduce(_ processor: TagProcessor<KindleState>) -> Any? {
        return text
    }
}

class ListHandler: TagHandler<KindleState> {
    var list: [String] = []
    
    override func processor(_ processor: TagProcessor<KindleState>, foundTag tag: String, value: Any) {
        if let string = value as? String {
            list.append(string)
        }
    }
    
    override func reduce(_ processor: TagProcessor<KindleState>) -> Any? {
        return list
    }
}

class MetadataHandler: TagHandler<KindleState> {
    var properties: [String:Any] = [:]
    
    override func processor(_ processor: TagProcessor<KindleState>, foundTag tag: String, value: Any) {
        properties[tag] = value
    }
    
    override func reduce(_ processor: TagProcessor<KindleState>) -> Any? {
        if let title = properties["title"] as? String,
            let authors = properties["authors"] as? [String],
            let publishers = properties["publishers"] as? [String],
            let asin = properties["ASIN"] as? String,
            let type = properties["cde_contenttype"] as? String {
            
            // skip samples and the built-in dictionaries
            if (type == "EBOK") && (title != "---------------") {
                processor.state.books.append(KindleBook(title: title, authors: authors, publishers: publishers, asin: asin, raw: properties))
            } else {
                kindleChannel.log("Skipped type \(type) \(title)")
            }
        }
        return nil
    }
}

class KindleProcessor: TagProcessor<KindleState> {
    override init() {
        super.init()
        register(handler: MetadataHandler.self, for: ["meta_data"])
        register(handler: ListHandler.self, for: ["authors", "publishers"])
        register(handler: StringHandler.self, for: ["title", "author", "publisher", "ASIN", "cde_contenttype", "content_type", "textbook_type"])
        register(handler: DateHandler.self, for: ["publication_date", "purchase_date"])
    }

    override var parser: TagParser? {
        return XMLTagParser(processor: self)
    }
}

class KindleImportSession: URLImportSession {
    var cachedPeople: [String:Person] = [:]
    var cachedPublishers: [String:Publisher] = [:]
    var cachedSeries: [String:Series] = [:]
    let kindleTag: EntityReference
    let includeRaw = true
    let books: [KindleBook]

    override init?(importer: Importer, store: Datastore, url: URL, monitor: ImportDelegate?) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let processor = KindleProcessor()
        processor.parse(data: data) // TODO: check if this fails
        self.books = processor.state.books
        self.kindleTag = Tag(identifiedBy: "tag-kindle", with: [.name: "kindle"])

        super.init(importer: importer, store: store, url: url, monitor: monitor)
    }
    
    override func run() {
        let store = self.store
        let monitor = self.monitor
        monitor?.importerWillStartSession(self, withCount: books.count)
        var item = 0
        var properties: [EntityReference] = []
        for kindleBook in books {
            if let identifier = identifier(for: kindleBook) {
                let book = Entity.identifiedBy(identifier, createAs: .book)
                monitor?.importerWillContinueSession(self, withItem: item, of: books.count)
                addProperties(for: book, identifier: identifier, from: kindleBook, into: &properties)
            }
            item += 1
        }

        store.add(properties: properties) {
            monitor?.importerDidFinishWithStatus(.succeeded(self))
        }
    }
    
    func identifier(for kindleBook: KindleBook) -> String? {
        let identifier: String
        let purchased = kindleBook.raw["purchase_date"] as? Date
        if let purchased = purchased {
            identifier = "kindle-import-\(kindleBook.asin)-\(purchased.timeIntervalSinceReferenceDate)"
        } else {
            identifier = "kindle-import-\(kindleBook.asin)"
        }
        return identifier
    }

    private func addProperties(for book: EntityReference, identifier bookID: String, from kindleBook: KindleBook, into properties: inout [EntityReference]) {
        var bookProperties = PropertyDictionary()

        bookProperties[.name] = kindleBook.title
        bookProperties[.source] = KindleImporter.identifier
        bookProperties[.importDate] = Date()
        bookProperties[.asin] = kindleBook.asin
        bookProperties[.format] = "Kindle Edition"

        bookProperties.addTag(kindleTag)
        bookProperties.addTag(importedTag)
        
        bookProperties.extract(from: kindleBook.raw, datesWithMapping: [
            "publication_date": .published,
            "purchase_date": .added
            ]
        )

        if includeRaw {
            bookProperties[.importRaw] = kindleBook.raw.jsonDump()
        }

        addProperties(for: kindleBook, creators: kindleBook.authors, into: &bookProperties)
        addProperties(for: kindleBook, publishers: kindleBook.publishers, into: &bookProperties)
        
        book.addUpdates(bookProperties)
        properties.append(book)
    }
    
    private func addProperties(for book: KindleBook, creators: [String], into properties: inout PropertyDictionary) {
        var index = 1
        for creator in creators {
            let unsorted = Indexing.nameUnsort(for: creator) ?? ""
            let trimmed = unsorted.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let identifier = "\(book.asin)-author-\(index)"
                let author = Person(named: trimmed, with: [.source: KindleImporter.identifier, .identifier: identifier])
                properties.addRole(PropertyType.author, for: author)
                index += 1
            }
        }
    }
    
    private func addProperties(for book: KindleBook, publishers: [String], into properties: inout PropertyDictionary) {
        for publisher in publishers {
            let trimmed = publisher.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let publisher = Publisher(named: trimmed, with: [.source: KindleImporter.identifier])
                properties.addPublisher(publisher)
            }
        }
    }
    
}

