// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Series: ChangeTrackingModelObject {
    
    override public class func getProvider() -> DetailProvider {
        return SeriesDetailProvider()
    }
    
    override public func updateSortName() {
        sortName = Indexing.titleSort(for: name)
    }

    @objc dynamic var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }

}
