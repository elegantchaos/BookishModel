// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public final class DetailSpec {
    
    public let binding: String
    public let label: String
    public let kind: String
    public let editableKind: String
    
    public static let textKind = "text"
    public static let dateKind = "date"
    public static let hiddenKind = "hidden"
    public static let editableDateKind = "editableDate"
    public static let editableDimensionsKind = "editableDimensions"
    
    public init(binding: String, label: String? = nil, viewAs: String = "text", editAs: String? = nil) {
        self.binding = binding
        self.label = label ?? binding.capitalized
        self.kind = viewAs
        self.editableKind = editAs ?? viewAs
    }
    
    public class var standardDetails: [DetailSpec] {
        var details = [
            DetailSpec(binding: "notes"),
            DetailSpec(binding: "format"),
            DetailSpec(binding: "identifier", viewAs: textKind, editAs: hiddenKind),
            DetailSpec(binding: "isbn", label: "ISBN", viewAs: hiddenKind, editAs: textKind),
            DetailSpec(binding: "asin", label:"ASIN", viewAs: hiddenKind, editAs: textKind),
            DetailSpec(binding: "ean", label: "EAN", viewAs: hiddenKind, editAs: textKind),
            DetailSpec(binding: "classification"),
            DetailSpec(binding: "published", viewAs: dateKind, editAs: editableDateKind),
            DetailSpec(binding: "added", viewAs: dateKind),
            DetailSpec(binding: "modified", viewAs: dateKind),
            DetailSpec(binding: "importDate", label: "Imported", viewAs: dateKind, editAs: hiddenKind),
            DetailSpec(binding: "dimensions", viewAs: textKind, editAs: editableDimensionsKind),
            DetailSpec(binding: "pages")
        ]
        
        #if DEBUG
        details.append(contentsOf: [
            DetailSpec(binding: "uuid", viewAs: textKind),
            DetailSpec(binding: "importRaw", label: "Raw (Debug)", viewAs: hiddenKind, editAs: textKind),
        ])
        #endif
        
        return details
    }
}
