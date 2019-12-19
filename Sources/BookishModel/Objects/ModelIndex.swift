// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 15/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Foundation
//
//public protocol ModelIndexClient: NSObjectProtocol {
//    func loaded()
//    func updating()
//    func inserted(section index: Int)
//    func deleted(section index: Int)
//    func inserted(row index: IndexPath)
//    func deleted(row index: IndexPath)
//    func updated(object: ModelObject, row index: IndexPath)
//    func moved(object: ModelObject, row fromIndex: IndexPath, to toIndex: IndexPath)
//    func updated()
//}
//
//public class ModelIndex: NSObject {
//    static let useSectionThreshold = 20
//
//    public let name: String
//    public let cacheName: String
//    public let type: ModelObject.Type
//    public let context: NSManagedObjectContext
//    public let request: NSFetchRequest<ModelObject>
//    public let fetcher: NSFetchedResultsController<ModelObject>
//    public let sorting: [NSSortDescriptor]
//
//    public var selection = ModelSelection()
//    public var clients: [ModelIndexClient]
//    
//
//    public init(type: ModelObject.Type, context: NSManagedObjectContext) {
//        self.type = type
//        self.name = type.entityName
//        self.cacheName = "\(name)-cache"
//        self.context = context
//        self.sorting = BookishModel.defaultSorting[name]!
//        self.clients = []
//        self.request = NSFetchRequest<ModelObject>()
//        request.entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[name]
//        request.fetchBatchSize = 20
//        request.sortDescriptors = sorting
//
//        let sectionPath: String?
//        if let count = try? context.count(for: request), count > ModelIndex.useSectionThreshold {
//            sectionPath = "sectionName"
//        } else {
//            sectionPath = nil
//        }
//
//        self.fetcher = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionPath, cacheName: cacheName)
//        
//        super.init()
//        fetcher.delegate = self
//        fetch(filter: "")
//    }
//    
//    public func add(client: ModelIndexClient) {
//        clients.append(client)
//        client.loaded()
//    }
//    
//    public func remove(client: ModelIndexClient) {
//        if let index = clients.firstIndex(where: { $0 === client }) {
//            clients.remove(at: index)
//        }
//    }
//    
//    public func fetch(filter: String) {
//        let predicate = filter.isEmpty ? nil : NSPredicate(format: "(name contains[cd] %@) or (SUBQUERY(tagsR, $x, $x.name contains[cd] %@).@count > 0)", filter, filter)
//        fetcher.fetchRequest.predicate = predicate
//        
//        do {
//            NSFetchedResultsController<ModelObject>.deleteCache(withName: cacheName)
//            try fetcher.performFetch()
//            clients.forEach({ $0.loaded() })
//        } catch let err {
//            print(err)
//        }
//    }
//
//    public var sections: Int {
//        return fetcher.sections?.count ?? 1
//    }
//    
//    public var sectionTitles: [String]? {
//        return fetcher.sectionIndexTitles
//    }
//    
//    public func title(forSection section: Int) -> String? {
//        guard fetcher.sectionIndexTitles.count > section else { return nil }
//        return fetcher.sectionIndexTitle(forSectionName: fetcher.sectionIndexTitles[section])
//    }
//    
//    
//    public var count: Int {
//        return fetcher.fetchedObjects?.count ?? 0
//    }
//    
//    public var objects: [ModelObject] {
//        return fetcher.fetchedObjects ?? []
//    }
//    
//    public var selectedIndexPaths: [IndexPath] {
//        var paths: [IndexPath] = []
//        for object in selection.objects {
//            if let index = fetcher.indexPath(forObject: object) {
//                paths.append(index)
//            }
//        }
//        return paths
//    }
//}
//
//
//extension ModelIndex: NSFetchedResultsControllerDelegate {
//    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        clients.forEach({ $0.updating() })
//    }
//    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex index: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            clients.forEach({ $0.inserted(section: index) })
//        case .delete:
//            clients.forEach({ $0.deleted(section: index) })
//        default:
//            return
//        }
//    }
//    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let path = newIndexPath { clients.forEach({ $0.inserted(row: path) }) }
//            
//        case .delete:
//            if let path = indexPath { clients.forEach({ $0.deleted(row: path) }) }
//            
//        case .update:
//            
//            if let path = indexPath { clients.forEach({ $0.updated(object: object as! ModelObject, row: path) }) }
//            
//        case .move:
//            if let path = indexPath, let newPath = newIndexPath {
//                clients.forEach({ $0.moved(object: object as! ModelObject, row: path, to: newPath) })
//            }
//            
//        @unknown default:
//            break
//        }
//    }
//    
//    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        clients.forEach({ $0.updated() })
//    }
//    
//}
//
//public protocol ModelSorting {
//    var showDebug: Bool { get set }
//    var seriesEntrySorting: [NSSortDescriptor] { get }
//    var relationshipSorting: [NSSortDescriptor] { get }
//    var bookSorting: [NSSortDescriptor] { get }
//    var peopleSorting: [NSSortDescriptor] { get }
//}
//
//public protocol ModelSession: ModelSorting {
//    var books: ModelIndex { get }
//    var people: ModelIndex { get }
//    var publishers: ModelIndex { get }
//    var series: ModelIndex { get }
//    var roles: ModelIndex { get }
//}
//
//extension ModelSession {
//    public var bookSorting: [NSSortDescriptor] { return books.sorting }
//    public var peopleSorting: [NSSortDescriptor] { return people.sorting }
//}
//
//extension ModelSession {
//    public var indexes: [ModelIndex] {
//        return [ books, people, publishers, series, roles ]
//    }
//}
