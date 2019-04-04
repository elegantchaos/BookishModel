// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

import Foundation
import CoreData
import JSONDump
import Logger

let kindleChannel = Logger("KindleImporter")

public class KindleImporter: Importer {
    
    public init(manager: ImportManager) {
        super.init(name: "Kindle", source: .userSpecifiedFile, manager: manager)
    }
    
    override func makeSession(importing url: URL, into context: NSManagedObjectContext, completion: @escaping ImportSession.Completion) -> ImportSession {
        return KindleImportSession(importer: self, context: context, url: url, completion: completion)
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
            let asin = properties["ASIN"] as? String {
            processor.state.books.append(KindleBook(title: title, authors: authors, publishers: publishers, asin: asin, raw: properties))
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

class KindleImportSession: ImportSession {
    typealias Record = [String:Any]
    typealias RecordList = [Record]
    
    var cachedPeople: [String:Person] = [:]
    var cachedPublishers: [String:Publisher] = [:]
    var cachedSeries: [String:Series] = [:]
    
    let formatsToSkip = ["Audio CD", "Audio CD Enhanced", "Audio CD Import", "Video Game", "VHS Tape", "VideoGame", "DVD"]
    
    let seriesNameBookPattern = try! NSRegularExpression(pattern: "(.*)\\((.*)S[.]{0,1}\\)")
    let seriesSPattern = try! NSRegularExpression(pattern: "(.*)\\((.*)S[.]{0,1}\\)")
    let seriesPattern = try! NSRegularExpression(pattern: "(.*)\\((.*)\\)$")
    let bookIndexPatterns = [
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} Bk\\.{0,1} *(\\d+)"),
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} Book\\.{0,1} *(\\d+)"),
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} No\\.{0,1} *(\\d+)")
    ]
    
    
    override func run() {
        if let data = try? Data(contentsOf: url) {
            let processor = KindleProcessor()
            processor.parse(data: data)
            for book in processor.state.books {
                process(book: book)
            }
        }
    }
    
    private func process(book kindleBook: KindleBook) {
        let book = Book(context: context)
        book.name = kindleBook.title
        book.importDate = Date()
        book.asin = kindleBook.asin
        book.importRaw = kindleBook.raw.jsonDump()
        process(creators: kindleBook.authors, for: book)
        process(publishers: kindleBook.publishers, for: book)
    }
    
    private func process(creators: [String], for book: Book) {
        var index = 1
        for creator in creators {
            let trimmed = creator.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let author: Person
                if let cached = cachedPeople[trimmed] {
                    author = cached
                } else {
                    author = Person(context: context)
                    author.name = trimmed
                    author.uuid = "\(book.uuid!)-author-\(index)"
                    index += 1
                    cachedPeople[trimmed] = author
                }
                let relationship = author.relationship(as: Role.StandardName.author)
                relationship.addToBooks(book)
            }
        }
    }
    
    private func process(publishers: [String], for book: Book) {
        for publisher in publishers {
            let trimmed = publisher.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed != "" {
                let publisher: Publisher
                if let cached = cachedPublishers[trimmed] {
                    publisher = cached
                } else {
                    publisher = Publisher(context: context)
                    publisher.name = trimmed
                    cachedPublishers[trimmed] = publisher
                }
                publisher.addToBooks(book)
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
                series = Series(context: context)
                series.name = trimmed
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

