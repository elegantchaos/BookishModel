// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public class Series: ModelObject {
    public override class func staticType() -> EntityType {
        return .series
    }

    override public class func getProvider() -> DetailProvider {
        return SeriesDetailProvider()
    }
    
    override public func updateSortName() {
        sortName = Indexing.titleSort(for: name)
    }
    
    var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }
}
