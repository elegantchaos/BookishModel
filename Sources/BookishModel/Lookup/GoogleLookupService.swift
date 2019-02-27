// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class GoogleLookupCandidate: LookupCandidate {
    let info: [String:Any]
    
    init(info: [String:Any], service: LookupService) {
        self.info = info
        super.init(service: service)
    }
    
    public override var summary: String {
        var summary = ""
        if let items = info["items"] as? [[String:Any]] {
            if items.count > 0, let item = items[0]["volumeInfo"] as? [String:Any] {
                if let title = item["title"] as? String {
                    summary += "\(title)\n"
                }
                if let authors = item["authors"] as? [String] {
                    summary += authors.joined(separator: ", ")
                    summary += "\n"
                }
                if let publisher = item["publisher"] as? String {
                    summary += "\(publisher)\n"
                }
                if let publishedDate = item["publishedDate"] as? String {
                    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
                    if let matches = detector?.matches(in: publishedDate, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: publishedDate.count)) {
                        if let date = matches.first?.date {
                            summary += "\(date)"
                        }
                    }
                }
            }
        }
        return summary
    }
}

public class GoogleLookupService: LookupService {
    
    public override func lookup(search: String, session: LookupSession) {
        guard
            let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(search)"),
            let data = try? Data(contentsOf: url),
            let parsed = try? JSONSerialization.jsonObject(with: data, options: []),
            let info = parsed as? [String:Any]
        else {
            session.failed(service: self)
            return
        }

        
        let candidate = GoogleLookupCandidate(info: info, service: self)
        session.add(candidate: candidate)
        session.done(service: self)
    }
}
