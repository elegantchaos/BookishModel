// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


public class BookDetailItem: DetailItem {
    public static let bookKind = "book"
    
    public let book: Book?
    
    public init(book: Book?, absolute: Int, index: Int, source: DetailProvider) {
        self.book = book
        super.init(kind: BookDetailItem.bookKind, absolute: absolute, index: index, placeholder: book == nil, source: source)
    }
    
    public override var heading: String {
        return ""
    }
}
