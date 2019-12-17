// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import Foundation

public class GoogleLookupCandidate: LookupCandidate {
    let info: [String:Any]
    
    class func isbn(from info: [String:Any]) -> String? {
        if let identifiers = info["industryIdentifiers"] as? [[String:Any]] {
            for id in identifiers {
                if let type = id["type"] as? String, let value = id["identifier"] as? String {
                    switch type {
                    case "ISBN_13":
                        return value
                        
                    case "ISBN_10":
                        return value.isbn10to13
                        
                    default:
                        break
                    }
                }
            }
        }
        return nil
    }
    
    init(info: [String:Any], service: GoogleLookupService) {
        let title = info["title"] as? String
        let authors = info["authors"] as? [String]
        let publisher = info["publisher"] as? String

        var date: Date? = nil
        if let publishedDate = info["publishedDate"] as? String {
            let matches = service.dateDetector.matches(in: publishedDate, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: publishedDate.count))
            date = matches.first?.date
        }
        
        var image: String? = nil
        if let images = info["imageLinks"] as? [String:Any] {
            image = (images["thumbnail"] as? String) ?? (images["smallThumbnail"] as? String)
            image = image?.replacingOccurrences(of: "edge=curl&", with: "")
            image = image?.replacingOccurrences(of: "http://", with: "https://")
//            image = image?.replacingOccurrences(of: "zoom=1&", with: "")
        }

        self.info = info
        super.init(service: service, title: title, authors: authors, publisher: publisher, date: date, image: image)
    }
    
    public override var summary: String {
        let authors = self.authors.joined(separator: ", ")

        return "\(title)\n\(authors)\n\(publisher)"
    }
    
    public override var action: String {
        return "AddCandidate"
    }
    
    public override func makeBook(in store: Datastore, completion: @escaping (Book) -> Void) {
//        let info = self.info
//        super.makeBook(in: store) { book in
//            if let pages = info["pageCount"] as? NSNumber {
//                book.pages = pages.int16Value
//            }
//            
//            if let isbn = GoogleLookupCandidate.isbn(from: info) {
//                book.isbn = isbn
//            }
//            
//            if let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted) {
//                book.importRaw = String(data: data, encoding: .utf8)
//            }
//            completion(book)
//        }
    }
}

public class GoogleLookupService: LookupService {
    var fetcher: DataFetcher = JSONDataFetcher()
    let dateDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)

    public override func lookup(search: String, session: LookupSession) {
        let isISBN = search.isISBN10 || search.isISBN13
        let query = isISBN ? "q=isbn:\(search)" : "q=\(search.replacingOccurrences(of: " ", with: "+"))"
        var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")
        components?.query = query
        guard
            let url = components?.url,
            let info = fetcher.info(for: url),
            let items = info["items"] as? [[String:Any]],
            items.count > 0
        else {
            session.failed(service: self)
            return
        }
        
        lookupChannel.log("Query \(query)")
        for item in items {
            if let volume = item["volumeInfo"] as? [String:Any] {
                let candidate = GoogleLookupCandidate(info: volume, service: self)
                session.add(candidate: candidate)
            }
        }

        session.done(service: self)
    }
}
