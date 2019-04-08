// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class GoogleLookupCandidate: LookupCandidate {
    let info: [String:Any]
    
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
            image = images["thumbnail"] as? String
        }

        self.info = info
        super.init(service: service, title: title, authors: authors, publisher: publisher, date: date, image: image)
    }
    
    public override var summary: String {
        let authors = self.authors.joined(separator: ", ")

        return "\(title)\n\(authors)\n\(publisher)"
    }
    
    public override func makeBook(in context: NSManagedObjectContext) -> Book {
        let book = super.makeBook(in: context)
        if let pages = info["pageCount"] as? NSNumber {
            book.pages = pages.int16Value
        }
        
        if let identifiers = info["industryIdentifiers"] as? [[String:Any]] {
            for id in identifiers {
                if let type = id["type"] as? String {
                    switch type {
                    case "ISBN_13":
                        let value = id["identifier"] as? String
                        book.isbn = value
                        book.ean = value
                        
                    case "ISBN_10":
                        if book.isbn == nil {
                            book.isbn = id["identifier"] as? String
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted) {
            book.importRaw = String(data: data, encoding: .utf8)
        }

        return book
    }
}

public class GoogleLookupService: LookupService {
    let dateDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)

    public override func lookup(search: String, session: LookupSession) {
        let query = (search.isISBN10 || search.isISBN13) ? "q=isbn:\(search)" : "q=\(search.replacingOccurrences(of: " ", with: "+"))"
        guard
            let url = URL(string: "https://www.googleapis.com/books/v1/volumes?\(query)"),
            let data = try? Data(contentsOf: url),
            let parsed = try? JSONSerialization.jsonObject(with: data, options: []),
            let info = parsed as? [String:Any],
            let items = info["items"] as? [[String:Any]],
            items.count > 0
        else {
            session.failed(service: self)
            return
        }
        
        for item in items {
            if let volume = item["volumeInfo"] as? [String:Any] {
                let candidate = GoogleLookupCandidate(info: volume, service: self)
                session.add(candidate: candidate)
            }
        }

        session.done(service: self)
    }
}
