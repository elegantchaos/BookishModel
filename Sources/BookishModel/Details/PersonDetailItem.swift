// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class PersonDetailItem: DetailItem {
    public var person: Person? { return object as? Person }
    
    public init(person: Person? = nil, absolute: Int, index: Int, source: DetailProvider) {
        super.init(kind: "person", absolute: absolute, index: index, placeholder: person == nil, source: source, object: person)
    }
    
    public override var heading: String {
        return ""
    }
}
