// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public final class DetailSpec {
    public enum Kind: String {
        case heading
        case text
        case date
        case person
        case editableDate
        case editablePerson
        case editableDimensions
    }

    public let binding: String
    public let label: String
    public let kind: Kind
    public let editableKind: Kind
    
    public init(binding: String, label: String? = nil, viewAs: Kind = .text, editAs: Kind? = nil) {
        self.binding = binding
        self.label = label ?? binding.capitalized
        self.kind = viewAs
        self.editableKind = editAs ?? viewAs
    }
    
    public class var standardDetails: [DetailSpec] {
        return [
            DetailSpec(binding: "notes"),
            DetailSpec(binding: "format"),
            DetailSpec(binding: "isbn10", label: "ISBN"),
            DetailSpec(binding: "isbn13", label: "ISBN"),
            DetailSpec(binding: "asin", label: "ASIN"),
            DetailSpec(binding: "ean", label: "EAN"),
            DetailSpec(binding: "dewey"),
            DetailSpec(binding: "published", viewAs: .date, editAs: .editableDate),
            DetailSpec(binding: "added", viewAs: .date),
            DetailSpec(binding: "modified", viewAs: .date),
            DetailSpec(binding: "importDate", label:  "Imported", viewAs: .date),
            DetailSpec(binding: "dimensions", label: "size", viewAs: .text, editAs: .editableDimensions),
            DetailSpec(binding: "pages"),
            DetailSpec(binding: "importRaw", label: "Raw (Debug)"),
        ]
    }
}
