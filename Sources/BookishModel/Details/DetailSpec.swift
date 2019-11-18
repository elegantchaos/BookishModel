// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public final class DetailSpec {
    
    public let binding: String
    public let kind: String
    public let editableKind: String
    public let isDebug: Bool
    
    public static let textKind = "text"
    public static let paragraphKind = "paragraph"
    public static let numberKind = "number"
    public static let tagsKind = "tags"
    public static let dateKind = "date"
    public static let timeKind = "time"
    public static let hiddenKind = "hidden"
    public static let editableDateKind = "editableDate"
    public static let dimensionsKind = "dimensions"
    
    public init(binding: String, viewAs: String = "text", editAs: String? = nil, isDebug: Bool = false) {
        self.binding = binding
        self.kind = viewAs
        self.editableKind = editAs ?? viewAs
        self.isDebug = isDebug
    }
    
}
