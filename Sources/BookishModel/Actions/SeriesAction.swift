// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData
import Actions

/**
 Protocol providing user interface actions.
 These aren't implemented in the model, but the protocol is defined
 here so that we can implement actions using it.
 */

public protocol SeriesViewer {
    func reveal(series: Series)
}

/**
 Objects that want to observe changes to seriess
 should implement this protocol.
 */

public protocol SeriesChangeObserver: ActionObserver {
    func added(series: Series)
    func removed(series: Series)
}

/**
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol SeriesConstructionObserver: ActionObserver {
    func created(series: Series)
    func deleted(series: Series)
}

/**
 Common functionality for all Series-related actions.
 */

open class SeriesAction: ModelAction {
    public static let newSeriesKey = "newSeries"
    public static let seriesKey = "series"
    
    open override func validate(context: ActionContext) -> Bool {
        guard super.validate(context: context) else {
            return false
        }
        
        guard let selection = context[ActionContext.selectionKey] as? [Book] else {
            return false
        }
        
        return selection.count > 0
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewSeriesAction(identifier: "NewSeries"),
            AddSeriesAction(identifier: "AddSeries"),
            RemoveSeriesAction(identifier: "RemoveSeries"),
            DeletePeopleAction(identifier: "DeleteSeries"),
            RevealSeriesAction(identifier: "RevealSeries"),
            ChangeSeriesAction(identifier: "ChangeSeries")
        ]
    }
}

/**
 Action that adds a relationship between a book and a newly created Series.
 */

class AddSeriesAction: SeriesAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let series = context[SeriesAction.seriesKey] as? Series {
            for book in selection {
                let entry = Entry(context: model)
                entry.book = book
                series.addToEntries(entry)
            }
            
            context.info.forObservers { (observer: SeriesChangeObserver) in
                observer.added(series: series)
            }
        }
    }
}

/**
 Action that removes a relationship from a book.
 */

class RemoveSeriesAction: SeriesAction {
    public override func validate(context: ActionContext) -> Bool {
        return (context[SeriesAction.seriesKey] as? Series != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let series = context[SeriesAction.seriesKey] as? Series {
            for book in selection {
                if book.series?.series == series {
                    book.series = nil
                }
            }
            
            context.info.forObservers { (observer: SeriesChangeObserver) in
                observer.removed(series: series)
            }
        }
        
    }
}

/**
 Action that creates a new Series.
 */

class NewSeriesAction: ModelAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let series = Series(context: model)
        context.info.forObservers { (observer: SeriesConstructionObserver) in
            observer.created(series: series)
        }
    }
}

/**
 Action that deletes a Series.
 */

class DeleteSeriesAction: ModelAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Series] {
            for series in selection {
                context.info.forObservers { (observer: SeriesConstructionObserver) in
                    observer.deleted(series: series)
                }
                
                model.delete(series)
            }
        }
    }
}

/**
 Action that reveals a Series in the UI.
 */

class RevealSeriesAction: SeriesAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[SeriesAction.seriesKey] as? Series != nil) && super.validate(context: context)
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let viewer = context[ActionContext.rootKey] as? SeriesViewer {
            if let series = context[SeriesAction.seriesKey] as? Series {
                viewer.reveal(series: series)
            }
        }
    }
}

/**
 Action that updates an existing role by changing the Series that
 it applies to.
 */

class ChangeSeriesAction: SeriesAction {
    override func validate(context: ActionContext) -> Bool {
        return (context[SeriesAction.seriesKey] as? Relationship != nil) && super.validate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
//        if let selection = context[ActionContext.selectionKey] as? [Book] {
//            var newSeries = context[SeriesAction.seriesKey] as? Series
//            if newSeries == nil, let newSeriesName = context[SeriesAction.newSeriesKey] as? String {
//                print("Made new Series \(newSeriesName)")
//                newSeries = Series(context: model)
//                newSeries?.name = newSeriesName
//            }
//
////            if let newSeries = newSeries {
////                for book in selection {
//////                    newSeries.addToBooks(book)
//////                    print("series changed from \(book.series!.name!) to \(newSeries.name!)")
////                }
////            }
//        }
    }
}
