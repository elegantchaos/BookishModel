// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Logger

let modelChannel = Logger("Model")

public class BookishModel {
    enum Error: String, Swift.Error {
        case locatingModel = "couldn't locate model"
        case loadingModel = "couldn't load model"
    }
    
    static let version = "1.0.0"

    static var cachedModel: NSManagedObjectModel!
    
    public class func loadModel(bundle: Bundle = Bundle(for: BookishModel.self), forceLoad: Bool = false) -> NSManagedObjectModel {
        if (cachedModel == nil) || forceLoad {
            guard let url = bundle.url(forResource: "Collection", withExtension: "momd") else {
                modelChannel.fatal(Error.locatingModel)
            }
            
            guard let model = NSManagedObjectModel(contentsOf: url) else {
                modelChannel.fatal(Error.loadingModel)
            }
            
            modelChannel.debug("loaded collection model")
            cachedModel = model
        }
        
        return cachedModel
    }
}
