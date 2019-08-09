// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import CoreData

/**
 Action that merges together a number of books.
 The first book in the selection is treated as the primary, and is retained.
 All the other books are removed, after transferring any relationships and properties to the first book.
 */

class MergeBookAction: BookAction {
    func moveProperties(from: Book, to: Book, context: NSManagedObjectContext) -> String {
        var log = ""
        
        let propertiesToReplace = ["added", "asin", "classification", "format", "height", "imageData", "imageURL", "importDate", "isbn", "length", "modified", "name", "owner", "pages", "published", "read", "source", "subtitle", "weight", "width"]
        for property in propertiesToReplace {
            if let value = from.value(forKey: property) as? NSObject {
                if let existing = to.value(forKey: property) as? NSObject  {
                    if value != existing {
                        log += "- \(property) was: \(existing)\n"
                    }
                }
                to.setValue(value, forKey: property)
            }
        }

        let propertiesToMerge = ["importRaw", "notes"]
        for property in propertiesToMerge {
            if let value = from.value(forKey: property) as? NSString {
                if let existing = to.value(forKey: property) as? NSString  {
                    if value != existing {
                        to.setValue("\(existing)\n\n\(value)" , forKey: property)
                    }
                } else {
                    to.setValue(value, forKey: property)
                }
            }
        }

        return log
    }
    
    override func validate(context: ActionContext) -> Action.Validation {
        return validateSelection(type: Book.self, context: context, minimumToEnable: 2, usingPluralTitle: false)
    }
    
    override func perform(context: ActionContext, model: NSManagedObjectContext) {
        if let selection = context[ActionContext.selectionKey] as? [Book], let primary = selection.first {
            
            var log = primary.log ?? ""
            let others = Set(selection.dropFirst())
            bookActionChannel.log("Merging \(primary) with \(others)")
            var relationshipsToChange: [Relationship] = []
            for book in others {
                if let relationships = book.relationships as? Set<Relationship> {
                    relationshipsToChange.append(contentsOf: relationships)
                }
            }
            
            for relationship in relationshipsToChange {
                relationship.remove(others)
                relationship.add(primary)
            }
            
            for book in others {
                log += "\nMerged with \(book).\n"
                log += moveProperties(from: book, to: primary, context: model)
                model.delete(book)
            }
            
            primary.log = log
        }
    }
}
