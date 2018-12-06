// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class CollectionContainer: NSPersistentContainer {

    public override class func defaultDirectoryURL() -> URL {
        return super.defaultDirectoryURL().appendingPathComponent("BookishModel")
    }
    
    public init(name: String) {
        super.init(name: name, managedObjectModel: BookishModel.loadModel())
    }
}
