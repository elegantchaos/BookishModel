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
    
    override func makeSession(importing url: URL, in store: Datastore, monitor: ImportMonitor?) -> URLImportSession? {
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
//    let kindleTag: Tag
//    let importedTag: Tag
    let books: [KindleBook]
    
    override init?(importer: Importer, store: Datastore, url: URL, monitor: ImportMonitor?) {
//        kindleTag = Tag.named("kindle", in: context)
//        importedTag = Tag.named("imported", in: context)
//
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let processor = KindleProcessor()
        processor.parse(data: data) // TODO: check if this fails
        self.books = processor.state.books
        
        super.init(importer: importer, store: store, url: url, monitor: monitor)
    }
    
    override func run() {
        monitor?.importerWillStartSession(self, withCount: books.count)
        var item = 0
        for book in books {
            monitor?.importerWillContinueSession(self, withItem: item, of: books.count)
            process(book: book)
            item += 1
        }
        monitor?.importerDidFinishWithStatus(.succeeded(self))
    }
    
    private func process(book kindleBook: KindleBook) {
//
//        let identifier: String
//        let purchased = kindleBook.raw["purchase_date"] as? Date
//        if let purchased = purchased {
//            identifier = "kindle-import-\(kindleBook.asin)-\(purchased)"
//        } else {
//            identifier = "kindle-import-\(kindleBook.asin)"
//        }
//
//        // we try to find a book with the same uuid
//        // this is intended to ensure that if the same import runs multiple times,
//        // we won't keep making new copies of the same books
//        let book: Book
//        if let existing = Book.withIdentifier(identifier, in: context) {
//            book = existing
//        } else {
//            book = Book.named(kindleBook.title, in: context)
//            book.uuid = identifier
//            book.source = KindleImporter.identifier
//        }
//
//        kindleTag.addToBooks(book)
//        importedTag.addToBooks(book)
//
//        book.importDate = Date()
//        book.asin = kindleBook.asin
//        book.format = "Kindle Edition"
//
//        if let date = kindleBook.raw["publication_date"] as? Date {
//            book.published = date
//        }
//
//        if let date = purchased {
//            book.added = date
//        }
//
//        book.importRaw = kindleBook.raw.jsonDump()
//        process(creators: kindleBook.authors, for: book)
//        process(publishers: kindleBook.publishers, for: book)
    }
    
    private func process(creators: [String], for book: Book) {
//        var index = 1
//        for creator in creators {
//            let unsorted = Indexing.nameUnsort(for: creator) ?? ""
//            let trimmed = unsorted.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            if trimmed != "" {
//                let author: Person
//                if let cached = cachedPeople[trimmed] {
//                    author = cached
//                } else {
//                    author = Person.named(trimmed, in: context)
//                    if author.source == nil {
//                        author.source = KindleImporter.identifier
//                        author.uuid = "\(book.asin!)-author-\(index)"
//                    }
//                    index += 1
//                    cachedPeople[trimmed] = author
//                }
//                let relationship = author.relationship(as: Role.StandardName.author)
//                relationship.add(book)
//            }
//        }
    }
    
    private func process(publishers: [String], for book: Book) {
//        for publisher in publishers {
//            let trimmed = publisher.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            if trimmed != "" {
//                let publisher: Publisher
//                if let cached = cachedPublishers[trimmed] {
//                    publisher = cached
//                } else {
//                    publisher = Publisher.named(trimmed, in: context)
//                    if publisher.source == nil {
//                        publisher.source = KindleImporter.identifier
//                    }
//                    cachedPublishers[trimmed] = publisher
//                }
//                publisher.add(book)
//            }
//        }
    }
    
}

