// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that adds a relationship between a book and a newly created Series.
 */

class AddSeriesAction: BookAction {
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book] {
            let series = Series(context: model)
            series.name = "New Series"
            for book in selection {
                let entry = SeriesEntry(context: model)
                entry.book = book
                entry.series = series
                entry.position = 1
            }

            context.info.forObservers { (observer: BookChangeObserver) in
                observer.added(series: series, position: 1)
            }

        }
    }
}
