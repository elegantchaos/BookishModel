// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Tag: ChangeTrackingModelObject {
    public func remove(from objects: [ModelObject]) {
        if let books = objects as? [Book] {
            removeFromBooks(NSSet(array: books))
        } else if let people = objects as? [Person] {
            removeFromPeople(NSSet(array: people))
        } else if let publishers = objects as? [Publisher] {
        removeFromPublishers(NSSet(array: publishers))
        } else if let series = objects as? [Series] {
            removeFromSeries(NSSet(array: series))
        }
    }

    public func add(to objects: [ModelObject]) {
        if let books = objects as? [Book] {
            addToBooks(NSSet(array: books))
        } else if let people = objects as? [Person] {
            addToPeople(NSSet(array: people))
        } else if let publishers = objects as? [Publisher] {
            addToPublishers(NSSet(array: publishers))
        } else if let series = objects as? [Series] {
            addToSeries(NSSet(array: series))
        }
    }
}

