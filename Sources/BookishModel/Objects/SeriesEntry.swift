// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

import CoreData

//public class SeriesEntry: ModelObject {
//    
//    /**
//     We should only have one entry for a given book/series pair, so the uuid is derived from their uuids.
//     */
//    
//    public override var uniqueIdentifier: NSObject {
//        guard let bookID = book?.uuid, let seriesID = series?.uuid else {
//            return ModelObject.missingUUID
//        }
//        
//        return "\(bookID)-\(seriesID)" as NSString
//    }
//    
//    /**
//     Since the uuid is calculated, we don't need to assign one initially.
//     */
//    
//    override func assignInitialUUID() {
//    }
//    
//    
//    public override var description: String {
//        var seriesName = series?.name ?? "<unknown>"
//        if let uuid = series?.uuid {
//            seriesName += " (\(uuid))"
//        }
//        
//        var bookName = book?.name ?? "<unknown>"
//        if let uuid = book?.uuid {
//            bookName += " (\(uuid))"
//        }
//        
//        let result = "<Entry: \(bookName) #\(position) in \(seriesName)>"
//        return result
//    }
//}
