// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public class Tag: ModelObject {
    public override class func staticType() -> DatastoreType {
        return .tag
    }
}

//
//public class Tag: ModelObject, ModelEntityCommon {
//    public func remove(from objects: [ModelObject]) {
//        if let books = objects as? [Book] {
//            removeFromBooks(NSSet(array: books))
//        } else if let people = objects as? [Person] {
//            removeFromPeople(NSSet(array: people))
//        } else if let publishers = objects as? [Publisher] {
//            removeFromPublishers(NSSet(array: publishers))
//        } else if let series = objects as? [Series] {
//            removeFromSeries(NSSet(array: series))
//        } else {
//            for object in objects {
//                if let book = object as? Book {
//                    removeFromBooks(book)
//                } else if let person = object as? Person {
//                    removeFromPeople(person)
//                } else if let publisher = object as? Publisher {
//                    removeFromPublishers(publisher)
//                } else if let series = object as? Series {
//                    removeFromSeries(series)
//                }
//            }
//        }
//    }
//
//    public func add(to objects: [ModelObject]) {
//        if let books = objects as? [Book] {
//            addToBooks(NSSet(array: books))
//        } else if let people = objects as? [Person] {
//            addToPeople(NSSet(array: people))
//        } else if let publishers = objects as? [Publisher] {
//            addToPublishers(NSSet(array: publishers))
//        } else if let series = objects as? [Series] {
//            addToSeries(NSSet(array: series))
//        } else {
//            for object in objects {
//                if let book = object as? Book {
//                    addToBooks(book)
//                } else if let person = object as? Person {
//                    addToPeople(person)
//                } else if let publisher = object as? Publisher {
//                    addToPublishers(publisher)
//                } else if let series = object as? Series {
//                    addToSeries(series)
//                }
//            }
//        }
//    }
//}
//
