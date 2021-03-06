// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that removes a relationship from a book.
 */

class RemoveSeriesAction: BookAction {
    public override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        info.enabled = info.enabled && (context[SeriesAction.seriesKey] as? Series != nil)
        return info
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if
            let selection = context[ActionContext.selectionKey] as? [Book],
            let series = context[SeriesAction.seriesKey] as? Series {
            for book in selection {
                book.removeFromSeries(series)
                context.info.forObservers { (observer: BookChangeObserver) in
                    observer.removed(series: series)
                }
            }
            
        }
        
    }
}
