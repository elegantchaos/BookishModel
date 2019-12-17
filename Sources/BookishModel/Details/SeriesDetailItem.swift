// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

//public class SeriesDetailItem: DetailItem {
//    public var entry: SeriesEntry? { return object as? SeriesEntry }
//    
//    public init(entry: SeriesEntry? = nil, absolute: Int, index: Int, source: DetailProvider) {
//        super.init(kind: "series", absolute: absolute, index: index, placeholder: entry == nil, source: source, object: entry)
//    }
//    
//    public override var heading: String {
//        return Series.entityLabel
//    }
//    
//    public override var removeAction: DetailItem.ActionSpec? {
//        if let entry = entry, let series = entry.series {
//            return ( .seriesKey, "button.RemoveSeries", series )
//        } else {
//            return super.removeAction
//        }
//    }
//
//    public override func matches(object: ModelObject) -> Bool {
//        if let series = object as? Series {
//            return entry?.series == series
//        } else {
//            return super.matches(object: object)
//        }
//    }
//}
