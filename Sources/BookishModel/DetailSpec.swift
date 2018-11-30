// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public final class DetailSpec {
    
    public enum Kind: String {
        case hidden
        case heading
        case text
        case date
        case person
        case publisher
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
            DetailSpec(binding: "identifier", viewAs: .text, editAs: .hidden),
            DetailSpec(binding: "isbn", label: "ISBN", viewAs: .hidden, editAs: .text),
            DetailSpec(binding: "asin", label: "ASIN", viewAs: .hidden, editAs: .text),
            DetailSpec(binding: "ean", label: "EAN", viewAs: .hidden, editAs: .text),
            DetailSpec(binding: "classification"),
            DetailSpec(binding: "published", viewAs: .date, editAs: .editableDate),
            DetailSpec(binding: "added", viewAs: .date),
            DetailSpec(binding: "modified", viewAs: .date),
            DetailSpec(binding: "importDate", label:  "Imported", viewAs: .date, editAs: .hidden),
            DetailSpec(binding: "dimensions", viewAs: .text, editAs: .editableDimensions),
            DetailSpec(binding: "pages"),
            DetailSpec(binding: "importRaw", label: "Raw (Debug)", viewAs: .hidden, editAs: .text),
        ]
    }
}
