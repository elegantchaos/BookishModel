// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class SeriesDetailItem: DetailItem {
    public let series: Series?
    
    public init(series: Series? = nil, absolute: Int, index: Int, source: DetailProvider) {
        self.series = series
        super.init(kind: "series", absolute: absolute, index: index, placeholder: series == nil, source: source)
    }
    
    public override var heading: String {
        return "Series"
    }
}
