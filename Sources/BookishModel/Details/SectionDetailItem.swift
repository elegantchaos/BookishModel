// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class SectionDetailItem: DetailItem {
    override public var heading: String {
        return ""
    }
    
    public override func viewID(for column: String) -> String {
        switch column {
        case DetailItem.detailColumnID:
            return "section"
        default:
            return super.viewID(for: column)
        }
    }
}
