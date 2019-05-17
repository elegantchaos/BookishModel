// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class TagsDetailItem: DetailItem {
    public var tags: Set<Tag>
    
    public init(tags: Set<Tag> = [], absolute: Int, index: Int, source: DetailProvider) {
        self.tags = tags
        super.init(kind: "tags", absolute: absolute, index: index, placeholder: false, source: source, object: nil)
    }
    
    public override var heading: String {
        return ""
    }
}
