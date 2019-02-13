// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class SeriesDetailItem: DetailItem {
    public var series: Series? { return object as? Series }
    
    public init(series: Series? = nil, absolute: Int, index: Int, source: DetailProvider) {
        super.init(kind: "series", absolute: absolute, index: index, placeholder: series == nil, source: source, object: series)
    }
    
    public override var heading: String {
        return "Series"
    }
    
    public override var removeAction: DetailItem.ActionSpec? {
        if let series = series {
            return ( SeriesAction.seriesKey, "button.RemoveSeries", series )
        } else {
            return super.removeAction
        }
        
    }
}
