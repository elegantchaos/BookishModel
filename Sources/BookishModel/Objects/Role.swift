// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Role: ModelObject {
    public struct StandardNames {
        public static let author = "Author"
        public static let contributor = "Contributor"
        public static let editor = "Editor"
        public static let foreword = "Foreword"
        public static let illustrator = "Illustrator"
        public static let translator = "Translator"

        public static var names: [String] { get { return [author, contributor, editor, foreword, illustrator, translator] } }
    }
    
    public class func named(_ name: String, in context: NSManagedObjectContext) -> Role {
        let request: NSFetchRequest<Role> = Role.fetchRequest()
        request.predicate = NSPredicate(format: "name = \"\(name)\"")

        let role: Role
        if let results = try? context.fetch(request), results.count > 0 {
            role = results[0]
        } else {
            let newRole = Role(context: context)
            newRole.name = name
            newRole.uuid = name
            role = newRole
        }
        
        return role
    }
    
    public class func named(_ name: String, in context: NSManagedObjectContext, createIfMissing: Bool = false) -> Role? {
        let request: NSFetchRequest<Role> = Role.fetchRequest()
        request.predicate = NSPredicate(format: "name = \"\(name)\"")
        
        if let results = try? context.fetch(request), results.count > 0 {
            return results[0]
        }
        
        if createIfMissing {
            let newRole = Role(context: context)
            newRole.name = name
            newRole.uuid = name
            return newRole
        }
        
        return nil
    }
    
    public class func allRoles(context: NSManagedObjectContext) -> [Role] {
        let result: [Role] = context.everyEntity(sorting: [NSSortDescriptor(key: "name", ascending: true)])
        return result
    }

     @objc public var lowercaseName: String? { return name?.lowercased() }
    
    @objc public var label: String? { return lowercaseName }
}
