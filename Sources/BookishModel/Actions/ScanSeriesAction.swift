// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Datastore

class ScanSeriesAction: ModelAction {
    override func perform(context: ActionContext, collection: CollectionContainer, completion: @escaping ModelAction.Completion) {
//        let scanner = SeriesScanner(context: model)
//        scanner.run()
        completion(.ok)
    }
}
