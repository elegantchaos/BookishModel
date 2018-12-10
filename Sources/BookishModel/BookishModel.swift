// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger

let modelChannel = Logger("Model")

enum BookishModelError: Error {
    case locatingModel
    case loadingModel
}

public class BookishModel {
    static let version = "1.0.0"
    
    static var cachedModel: NSManagedObjectModel!
    
    public class func loadModel(bundle: Bundle = Bundle(for: BookishModel.self), forceLoad: Bool = false) throws -> NSManagedObjectModel {
        if (cachedModel == nil) || forceLoad {
            guard let url = bundle.url(forResource: "Collection", withExtension: "momd") else {
                throw BookishModelError.locatingModel
            }
            
            guard let model = NSManagedObjectModel(contentsOf: url) else {
                throw BookishModelError.loadingModel
            }
            
            modelChannel.debug("loaded collection model")
            cachedModel = model
        }
        
        return cachedModel
    }
}
