// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public class Publisher: ModelObject {
    public override class func staticType() -> DatastoreType {
        return .publisher
    }
        override public class func getProvider() -> DetailProvider {
            return PublisherDetailProvider()
        }
    
        override public func updateSortName() {
            sortName = Indexing.titleSort(for: name)
        }

        var sectionName: String? {
            return Indexing.sectionName(for: sortName)
        }
}
//
//public class Publisher: ModelObject, ModelEntityCommon {
//
//
//    public var books: Set<Book> {
//        get { return booksR as! Set<Book> }
//        set { booksR = newValue as NSSet }
//    }
//
//    public func books(sortedBy sort: [NSSortDescriptor]) -> [Book] {
//        return booksR?.sortedArray(using: sort) as! [Book]
//    }
//    
//    public func add(_ book: Book) {
//        addToBooksR(book)
//    }
//    
//    public func remove(_ book: Book) {
//        removeFromBooksR(book)
//    }
//    
//    public var tags: Set<Tag> {
//        get { return tagsR as! Set<Tag> }
//        set { tagsR = newValue as NSSet }
//    }
//}
