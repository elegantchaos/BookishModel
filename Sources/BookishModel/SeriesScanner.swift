// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData
import Logger
import BookishCore
import Expressions

let seriesDetectorChannel = Logger("com.elegantchaos.bookish.model.SeriesDetector")

class SeriesDetector {
    static let bookPattern = "(Number |Book |Bk\\. |Bk\\.|Bk |No\\. |No\\.|No |)"
    
    struct Result {
        let name: String
        let subtitle: String
        let series: String
        let position: Int
        
    }

    internal struct Captured: Constructable {
        var name = ""
        var subtitle = ""
        var series = ""
        var rest = ""
        var extra = ""
        var position = 0
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
    // eg: "Effendi: The Second Arabesk (Arabesk S.)"
    let pattern = try! NSRegularExpression(pattern: "(.*) \\((.*) S[.]{0,1}\\)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.name: 1, \Captured.series: 2]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name, subtitle: matchedSubtitle, series: match.series, position: 0)
            }
        }
        
        return nil
    }
}

class SeriesBracketsBookDetector: SeriesDetector {
    // eg: name: "Carpe Jugulum (Discworld Novel)" subtitle: "Discworld Novel"
    let pattern = try! NSRegularExpression(pattern: "(.*) \\((.*)\\)$")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.name: 1, \Captured.series: 2]) {
            if let series = matchWithArticles(subtitle, match.series) {
                return Result(name: match.name, subtitle: "", series: series, position: 0)
            }
        }
        return nil
    }
}

class TitleInSeriesDetector: SeriesDetector {
    // eg: "The Fuller Memorandum: Book 3 in The Laundry Files"
    let pattern = try! NSRegularExpression(pattern: "(.*?)[:, ]+\(SeriesDetector.bookPattern)(\\d+) (in|of) (.*?)$")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.name: 1, \Captured.series: 5, \Captured.position: 3]) {
            return Result(name: match.name, subtitle: subtitle, series: match.series, position: match.position)
        }
        return nil
    }
}

class SeriesBracketsBookNumberDetector: SeriesDetector {
    // eg: "The Better Part of Valour: A Confederation Novel (Valour Confederation Book 2)"
    let pattern = try! NSRegularExpression(pattern: "(.*) \\(((.*?)[:, ]+\(SeriesDetector.bookPattern)(\\d+)(.*?))\\)$")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.name: 1, \Captured.series: 3, \Captured.position: 5, \Captured.rest: 6, \Captured.extra: 2]) {
            let combinedName = match.name + match.rest
            if subtitle == match.extra {
                return Result(name: combinedName, subtitle: "", series: match.series, position: match.position)
            } else if let series = matchWithArticles(subtitle, match.extra) {
                return Result(name: combinedName, subtitle: "", series: series, position: match.position)
            }
            return Result(name: combinedName, subtitle: subtitle, series: match.series, position: match.position)
        }
        return nil
    }
}

class SeriesNameBookDetector: SeriesDetector {
    // eg: "The Amtrak Wars: Cloud Warrior Bk. 1"
    let pattern = try! NSRegularExpression(pattern: "(.*?)\\:+ (.*?)\\:{0,1} \(SeriesDetector.bookPattern)(\\d+)(.*)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.series: 1, \Captured.name: 2, \Captured.position: 4, \Captured.rest: 5]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name + match.rest, subtitle: matchedSubtitle, series: match.series, position: match.position)
            }
        }
        
        return nil
    }
}

class NameSeriesBookBracketsDetector: SeriesDetector {
    // eg: "The Name of the Wind: The Kingkiller Chronicle: Book 1 (Kingkiller Chonicles)"
    let pattern = try! NSRegularExpression(pattern: "(.*?)\\:+ (.*?)\\:{0,1} \(SeriesDetector.bookPattern)(\\d+) \\((.*)\\)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.series: 2, \Captured.name: 1, \Captured.position: 4, \Captured.rest: 5]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name, subtitle: matchedSubtitle, series: match.series, position: match.position)
            }
        }
        
        return nil
    }
}

class NameBookSeriesBracketsSDetector: SeriesDetector {
    // eg: "Name Book 2 (Series S.)"
    let pattern = try! NSRegularExpression(pattern: "(.*?)\\:{0,1} \(SeriesDetector.bookPattern)(\\d+) \\((.*) S.\\)")
    
    override func detect(name: String, subtitle: String) -> Result? {
        if let match = pattern.firstMatch(in: name, capturing: [\Captured.series: 4, \Captured.name: 1, \Captured.position: 3]) {
            if !match.series.isEmpty && !name.isEmpty {
                let matchedSubtitle = subtitle.contains(match.series) ? "" : subtitle
                return Result(name: match.name, subtitle: matchedSubtitle, series: match.series, position: match.position)
            }
        }
        
        return nil
    }
}

class SubtitleBookDetector: SeriesDetector {
    // eg: "The Amber Citadel" subtitle: "Jewelfire Trilogy 1"
    // eg: name: "Ancillary Justice" subtitle: "(Imperial Radch Book 1)"
    var pattern: NSRegularExpression { return try! NSRegularExpression(pattern: "\\({0,1}(.*?)[:, ]+\(SeriesDetector.bookPattern)(\\d+)(.*?)\\){0,1}") }

    override func detect(name: String, subtitle: String) -> Result? {
        let mapping = [\Captured.series: 1, \Captured.position: 3, \Captured.rest: 4]
        if let match = pattern.firstMatch(in: subtitle, capturing: mapping) {
            if !match.series.isEmpty {
                let series = match.series + match.rest
                return Result(name: name, subtitle: "", series: series, position: match.position)
            }
        }
        
        return nil
    }
}

class SeriesScanner {
    typealias Record = [String:Any]
    typealias RecordList = [Record]
    
    var cachedSeries: [String:Series] = [:]
    
    let context: NSManagedObjectContext
    
    let detectors = [ NameSeriesBookBracketsDetector(), TitleInSeriesDetector(), SeriesBracketsBookNumberDetector(), SeriesBracketsBookDetector(), NameBookSeriesBracketsSDetector(), SeriesBracketsSBookDetector(), SubtitleBookDetector(), SeriesNameBookDetector()]
    
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
        let everySeries: [Series] = Series.everyEntity(in: context)
        for series in everySeries {
            if let name = series.name {
                cachedSeries[name] = series
            }
        }
    }
    
    public func run() {
        let books: [Book] = Book.everyEntity(in: context)
        var seriesAdded: Bool
        
        let partPattern: NSRegularExpression = try! NSRegularExpression(pattern: "(.*?) *(Part \\d+) *(.*?)")
        struct Part: Constructable {
            var before = ""
            var part = ""
            var after = ""
        }

        repeat {
            let seriesCount = context.countEntities(type: Series.self)
            for book in books {
                if book.entries?.count == 0 { // only apply to books not already in a series
                    for detector in detectors {
                        let name = book.name ?? ""
                        let subtitle = book.subtitle ?? ""
                        if let detected = detector.detect(name: name, subtitle: subtitle) {
                            if subtitle == "" {
                                seriesDetectorChannel.log("detected with \(detector) from \"\(name)\"")
                            } else {
                                seriesDetectorChannel.log("detected with \(detector) from name: \"\(name)\" subtitle: \"\(subtitle)\"")
                            }
                            book.name = detected.name
                            book.subtitle = detected.subtitle
                            var series = detected.series
                            if (series != "" && detected.position != 0) {
                                let mapping = [\Part.before: 1, \Part.part: 2, \Part.after: 3]
                                if let match = partPattern.firstMatch(in: detected.series, capturing: mapping) {
                                    book.name = detected.name + match.part
                                    series = match.before + match.after
                                }
                            }
                            seriesDetectorChannel.log("extracted <\(detected.name)> <\(detected.subtitle)> <\(series) \(detected.position)> from <\(name)> <\(subtitle)>")
                            process(series: series, position: detected.position, for: book)
                            break
                        }
                    }
                }
            }
            
            // if we added some more series, loop again
            seriesAdded = context.countEntities(type: Series.self) > seriesCount
        } while (seriesAdded)
        
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
                series.source = "com.elegantchaos.bookish.series-detection"
                cachedSeries[trimmed] = series
            }
            book.addToSeries(series, position: position)
        }
    }
}

