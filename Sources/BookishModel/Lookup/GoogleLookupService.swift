// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class GoogleLookupCandidate: LookupCandidate {
    let info: [String:Any]
    let title: String
    let authors: [String]
    let publisher: String
    let publicationDate: Date?
    let publicationYear: String
    
    init(info: [String:Any], service: GoogleLookupService) {
        let authors = info["authors"] as? [String]
        let publisher = info["publisher"] as? String
        var pubDate: Date? = nil
        var pubYear: String = ""
        
        if let publishedDate = info["publishedDate"] as? String {
            let matches = service.dateDetector.matches(in: publishedDate, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: publishedDate.count))
            if let date = matches.first?.date {
                pubYear = service.dateFormatter.string(from: date)
                pubDate = date
            }
            
        }
        
        self.info = info
        self.title = info["title"] as? String ?? ""
        self.authors = authors ?? []
        self.publisher = publisher ?? ""
        self.publicationYear = pubYear
        self.publicationDate = pubDate

        super.init(service: service)
    }
    
    public override var summary: String {
        let authors = self.authors.joined(separator: ", ")
        var publisher = self.publisher
        if !publicationYear.isEmpty {
            if !publisher.isEmpty {
                publisher += ", "
            }
            publisher += publicationYear
        }

        return "\(title)\n\(authors)\n\(publisher)"
    }
    
    public override func makeBook(in context: NSManagedObjectContext) -> Book {
        let book = super.makeBook(in: context)
        
        book.name = title
        if let images = info["imageLinks"] as? [String:Any] {
            book.imageURL = images["thumbnail"] as? String
        }
        
        if let authors = info["authors"] as? [String] {
            for author in authors {
                let person = Person.named(author, in: context)
                let relationship = person.relationship(as: Role.StandardName.author)
                book.addToRelationships(relationship)
            }
        }
        
        if let publisherName = info["publisher"] as? String {
            let publisher = Publisher.named(publisherName, in: context)
            book.publisher = publisher
        }

        book.pages = info["pageCount"] as? NSDecimalNumber
        
        if let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted) {
            book.importRaw = String(data: data, encoding: .utf8)
        }

        return book
    }
}

public class GoogleLookupService: LookupService {
    let dateDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    let dateFormatter = DateFormatter()
    
    public override init(name: String) {
        dateFormatter.dateFormat = "yyyy"
        super.init(name: name)
    }
    
    public override func lookup(search: String, session: LookupSession) {
        guard
            let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(search)"),
            let data = try? Data(contentsOf: url),
            let parsed = try? JSONSerialization.jsonObject(with: data, options: []),
            let info = parsed as? [String:Any],
            let items = info["items"] as? [[String:Any]],
            items.count > 0,
            let volume = items[0]["volumeInfo"] as? [String:Any]
        else {
            session.failed(service: self)
            return
        }

        
        let candidate = GoogleLookupCandidate(info: volume, service: self)
        session.add(candidate: candidate)
        session.done(service: self)
    }
}
