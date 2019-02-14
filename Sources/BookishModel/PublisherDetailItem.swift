// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class PublisherDetailItem: DetailItem {
    public var publisher: Publisher? { return object as? Publisher }
    
    public init(publisher: Publisher? = nil, absolute: Int, index: Int, source: DetailProvider) {
        super.init(kind: "publisher", absolute: absolute, index: index, placeholder: publisher == nil, source: source, object: publisher)
    }
    
    public override var heading: String {
        return Publisher.categoryLabel
    }
    
    public override var removeAction: DetailItem.ActionSpec? {
        if let publisher = publisher {
            return ( PublisherAction.publisherKey, "button.RemovePublisher", publisher )
        } else {
            return super.removeAction
        }
    }
    
}
