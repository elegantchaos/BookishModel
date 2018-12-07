// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData
import Logger

let seriesDetectorChannel = Logger("DeliciousImporter")

class SeriesDetector {
    static let bookPattern = "(Book |Bk\\. |Bk\\.|Bk |No\\. |No\\.|No |)"
    
    struct Result {
        let name: String
        let subtitle: String
        let series: String
        let index: Int
        
    }

    internal struct Captured: RegularExpressionResult {
        var name = ""
        var subtitle = ""
        var series = ""
        var rest = ""
        var index = 0
    }
    
    
    func detect(name: String, subtitle: String) -> Result? {
        return nil
    }
    
    func matchWithArticles(_ s1: String, _ s2: String) -> String? {
        if s1 == s2 {
            return s1
        }
        
        if let s = matchWithLeftArticle(s1, s2) {
            return s
        }

        if let s = matchWithLeftArticle(s2, s1) {
            return s
        }
        
        return nil
    }

    func matchWithLeftArticle(_ s1: String, _ s2: String) -> String? {
        if ("The " + s1) == s2 {
            return s1
        }
        
        if ("A " + s1) == s2 {
            return s1
        }
        
        return nil
    }

}

class SeriesBracketsSBookDetector: SeriesDetector {
    let pattern = try! NSRegularExpression(pattern: "(.*) \\((.*)S[.]{0,1}\\)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(of: name, capturing: [\Captured.name: 1, \Captured.series: 2]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name, subtitle: matchedSubtitle, series: match.series, index: 0)
            }
        }
        
        return nil
    }
}

class SeriesBracketsBookDetector: SeriesDetector {
    let pattern = try! NSRegularExpression(pattern: "(.*) \\((.*)\\)$")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(of: name, capturing: [\Captured.name: 1, \Captured.series: 2]) {
            if let series = matchWithArticles(subtitle, match.series) {
                return Result(name: match.name, subtitle: "", series: series, index: 0)
            }
        }
        return nil
    }
}

class SeriesNameBookDetector: SeriesDetector {
    let pattern = try! NSRegularExpression(pattern: "(.*?)\\:+ (.*?)\\:{0,1} \(SeriesDetector.bookPattern)(\\d+)(.*)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(of: name, capturing: [\Captured.series: 1, \Captured.name: 2, \Captured.index: 4, \Captured.rest: 5]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name + match.rest, subtitle: matchedSubtitle, series: match.series, index: match.index)
            }
        }
        
        return nil
    }
}

class NameBookSeriesBracketsSDetector: SeriesDetector {
    let pattern = try! NSRegularExpression(pattern: "(.*?)\\:{0,1} \(SeriesDetector.bookPattern)(\\d+) \\((.*) S.\\)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(of: name, capturing: [\Captured.series: 4, \Captured.name: 1, \Captured.index: 3]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name, subtitle: matchedSubtitle, series: match.series, index: match.index)
            }
        }
        
        return nil
    }
}

class SubtitleBookDetector: SeriesDetector {
    var pattern: NSRegularExpression { return try! NSRegularExpression(pattern: "(.*?)[:, ]+\(SeriesDetector.bookPattern)(\\d+)(.*)") }

    override func detect(name: String, subtitle: String) -> Result? {
        let mapping = [\Captured.series: 1, \Captured.index: 3, \Captured.rest: 4]
        if let match = pattern.firstMatch(of: subtitle, capturing: mapping) {
            if !match.series.isEmpty {
                let series = match.series + match.rest
                return Result(name: name, subtitle: "", series: series, index: match.index)
            }
        }
        
        return nil
    }
}

class SubtitleBracketsBookDetector: SubtitleBookDetector {
    override var pattern: NSRegularExpression { return try! NSRegularExpression(pattern: "\\((.*?)[:, ]+\(SeriesDetector.bookPattern)(\\d+)(.*)\\)") }
}

class SeriesScanner {
    typealias Record = [String:Any]
    typealias RecordList = [Record]
    
    
    var cachedPeople: [String:Person] = [:]
    var cachedPublishers: [String:Publisher] = [:]
    var cachedSeries: [String:Series] = [:]
    
    let context: NSManagedObjectContext
    
    let detectors = [ NameBookSeriesBracketsSDetector(), SeriesBracketsSBookDetector(), SeriesBracketsBookDetector(), SeriesNameBookDetector(), SubtitleBracketsBookDetector(), SubtitleBookDetector() ]
    
    let bookIndexPatterns = [
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} Bk\\.{0,1} *(\\d+)"),
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} Book\\.{0,1} *(\\d+)"),
        try! NSRegularExpression(pattern: "(.*)\\:{0,1} No\\.{0,1} *(\\d+)")
    ]
    
    init(context: NSManagedObjectContext) {
        self.context = context
        makeCaches()
    }
    
    private func makeCaches() {
        let everySeries: [Series] = context.everyEntity()
        for series in everySeries {
            if let name = series.name {
                cachedSeries[name] = series
            }
        }
        
        let everyPublisher: [Publisher] = context.everyEntity()
        for publisher in everyPublisher {
            if let name = publisher.name {
                cachedPublishers[name] = publisher
            }
        }
    }
    
    public func run() {
        let books: [Book] = context.everyEntity()
        
        var matched: Bool
        repeat {
            matched = false
            for book in books {
                for detector in detectors {
                    let name = book.name ?? ""
                    let subtitle = book.subtitle ?? ""
                    if let detected = detector.detect(name: name, subtitle: subtitle) {
                        book.name = detected.name
                        book.subtitle = detected.subtitle
                        seriesDetectorChannel.log("extracted <\(detected.name)> <\(detected.subtitle)> <\(detected.series) \(detected.index)> from <\(name)> <\(subtitle)>")
                        process(series: detected.series, index: detected.index, for: book)
                        matched = true
                    }
                }
            }
        } while (matched)
        
    }
    
    private func process(series: String, index: Int, for book: Book) {
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
            let entry = Entry(context: context)
            entry.book = book
            entry.series = series
            if index != 0 {
                entry.index = Int16(index)
            }
        }
    }
}

