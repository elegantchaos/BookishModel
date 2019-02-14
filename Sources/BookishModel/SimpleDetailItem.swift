// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class SimpleDetailItem: DetailItem {
    public let spec: DetailSpec
    
    public init(spec: DetailSpec, absolute: Int, index: Int, source: DetailProvider) {
        self.spec = spec
        let kind = source.isEditing ? spec.editableKind : spec.kind
        super.init(kind: kind, absolute: absolute, index: index, placeholder: false, source: source)
    }

    override public var heading: String {
        return "detail.label.\(spec.binding)".localized
    }
}
