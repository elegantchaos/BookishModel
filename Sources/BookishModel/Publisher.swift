// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Publisher: ModelObject {
    public override func didChangeValue(forKey key: String) { // TODO: not sure that this is the best approach...
        if key == "name" {
            sortName = Indexing.titleSort(for: name)
        }
        super.didChangeValue(forKey: key)
    }
    
    @objc dynamic var sectionName: String? {
        return Indexing.sectionName(for: sortName)
    }

}
