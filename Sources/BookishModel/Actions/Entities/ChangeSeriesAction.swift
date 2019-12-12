// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

/**
 Action that updates an existing role by changing the Series that
 it applies to.
 */

class ChangeSeriesAction: EntityAction {
    override func validate(context: ActionContext) -> Validation {
        var info = super.validate(context: context)
        let gotSeries =
            (context[.seriesKey] as? Series != nil) ||
                (context[.newSeriesKey] as? Series != nil) ||
                (context[.newSeriesKey] as? String != nil)
        info.enabled = info.enabled && gotSeries
        return info
    }
    
    override func perform(context: ActionContext, store: Datastore, completion: @escaping ModelAction.Completion) {
        completion(.ok)
//        if let selection = context[.selection] as? [Book] {
//            let existingSeries = context[SeriesAction.seriesKey] as? Series
//            let position = context[SeriesAction.positionKey] as? Int
//            var updatedSeries = context[SeriesAction.newSeriesKey] as? Series
//            
//            // if we weren't given a series, but were given a name, make a new series with that name
//            if updatedSeries == nil, let newSeriesName = context[SeriesAction.newSeriesKey] as? String, !newSeriesName.isEmpty {
//                updatedSeries = Series(context: model)
//                updatedSeries?.name = newSeriesName
//                bookActionChannel.log("Made new Series \(newSeriesName)")
//            }
//            
//            if let series = updatedSeries {
//                // we've got a series to change to, so do it
//                for book in selection {
//                    var bookPosition = position
//                    if let existingSeries = existingSeries {
//                        if bookPosition == nil {
//                            bookPosition = book.position(in: existingSeries)
//                        }
//                        book.removeFromSeries(existingSeries)
//                        bookActionChannel.debug("removed from \(existingSeries.name!)")
//                    }
//                    
//                    book.addToSeries(series, position: bookPosition ?? 0)
//                    bookActionChannel.debug("added to \(series.name!)")
//                }
//                if let existingSeries = existingSeries {
//                    context.info.forObservers { (observer: BookChangeObserver) in
//                        observer.changed(series: existingSeries, to: series, position: position ?? 0)
//                    }
//                } else {
//                    context.info.forObservers { (observer: BookChangeObserver) in
//                        observer.added(series: series, position: position ?? 0)
//                    }
//                }
//            } else if let existingSeries = existingSeries, let updatedPosition = position {
//                // we've not got a series to change to, but we might be updating our position
//                // in an existing series
//                for book in selection {
//                    book.setPosition(in: existingSeries, to: updatedPosition)
//                }
//                context.info.forObservers { (observer: BookChangeObserver) in
//                    observer.changed(series: existingSeries, to: existingSeries, position: position ?? 0)
//                }
//            }
//        }
    }
}
