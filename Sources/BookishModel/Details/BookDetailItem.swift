// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class BookDetailItem: DetailItem {
    public enum Mode {
        case publisher
        case series
        case person
    }
    
    public static let bookKind = "book"
    
    public let book: Book?
    public let mode: Mode
    
    public init(book: Book?, mode: Mode, absolute: Int, index: Int, source: DetailProvider) {
        self.book = book
        self.mode = mode
        super.init(kind: BookDetailItem.bookKind, absolute: absolute, index: index, placeholder: book == nil, source: source)
    }
    
    public override var heading: String {
        return ""
    }
}
