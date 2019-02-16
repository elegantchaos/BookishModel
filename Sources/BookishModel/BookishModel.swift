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
    
    public class func registerLocalizations() {
        StringLocalization.registerLocalizationBundle(Bundle(for: BookishModel.self))
    }
    
    public class func modelURL(bundle: Bundle = Bundle(for: BookishModel.self)) -> URL {
        guard let url = bundle.url(forResource: "Collection", withExtension: "momd") else {
            modelChannel.fatal(Error.locatingModel)
        }
        
        return url
    }
    
    public class func model(bundle: Bundle = Bundle(for: BookishModel.self), cached: Bool = true) -> NSManagedObjectModel {
        if cached && (cachedModel != nil) {
            return cachedModel
        }
        
        let url = BookishModel.modelURL(bundle: bundle)
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            modelChannel.fatal(Error.loadingModel)
        }
        
        modelChannel.debug("loaded collection model")
        if (cached) {
            cachedModel = model
        }

        return model
    }
}
