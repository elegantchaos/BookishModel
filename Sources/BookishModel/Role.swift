// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Role: ModelObject {
    public struct Default {
        public static let authorName = "Author"
        public static let contributorName = "Contributor"
        public static let editorName = "Editor"
        public static let forwordName = "Foreword"
        public static let illustratorName = "Illustrator"
        public static let translatorName = "Translator"

        public static var names: [String] { get { return [authorName, contributorName, editorName, forwordName, illustratorName, translatorName] } }
    }
    
    public class func role(named: String, context: NSManagedObjectContext) -> Role {
        let request: NSFetchRequest<Role> = Role.fetchRequest()
        request.predicate = NSPredicate(format: "name = \"\(named)\"")

        var role: Role
        if let results = try? context.fetch(request), results.count > 0 {
            role = results[0]
        } else {
            let newRole = Role(context: context)
            newRole.name = named
            newRole.uuid = named
            role = newRole
        }
        
        return role
    }
    
    public class func allRoles(context: NSManagedObjectContext) -> [Role] {
        let result: [Role] = context.everyEntity(sorting: [NSSortDescriptor(key: "name", ascending: true)])
        return result
    }

}
