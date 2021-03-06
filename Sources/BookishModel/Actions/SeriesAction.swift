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
 Objects that want to observe construction/destruction
 of people should implement this protocol.
 */

public protocol SeriesLifecycleObserver: ActionObserver {
    func created(series: Series)
    func deleted(series: Series)
}

/**
 Common functionality for all Series-related actions.
 */

open class SeriesAction: SyncModelAction {
    public static let newSeriesKey = "newSeries"
    public static let seriesKey = "series"
    public static let positionKey = "position"

    open override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        
        if let selection = context[ActionContext.selectionKey] as? [Series] {
            info.enabled = info.enabled && selection.count > 0
        } else {
            info.enabled = false
        }
        
        return info
    }
    
    open class override func standardActions() -> [Action] {
        return [
            NewSeriesAction(),
            DeleteSeriesAction(),
            RevealSeriesAction(),
            ChangeSeriesAction()
        ]
    }
}

/**
 Action that creates a new Series.
 */

class NewSeriesAction: SeriesAction {
    override func validate(context: ActionContext) -> Validation {
        return modelValidate(context: context)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        let series = Series(context: model)
        context.info.forObservers { (observer: SeriesLifecycleObserver) in
            observer.created(series: series)
        }
    }
}

/**
 Action that deletes a Series.
 */

class DeleteSeriesAction: SeriesAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Series] {
            for series in selection {
                context.info.forObservers { (observer: SeriesLifecycleObserver) in
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
    override func validate(context: ActionContext) -> Validation {
        var info = modelValidate(context: context)
        info.enabled = info.enabled && (context[SeriesAction.seriesKey] as? Series != nil)
        return info
    }
    
    public override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let viewer = context[ActionContext.rootKey] as? SeriesViewer {
            if let series = context[SeriesAction.seriesKey] as? Series {
                viewer.reveal(series: series)
            }
        }
    }
}
