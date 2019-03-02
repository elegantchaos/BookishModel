// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CoreData

public class Role: ModelObject {
    public enum StandardName: String, CaseIterable {
        case author = "Author"
        case contributor = "Contributor"
        case editor = "Editor"
        case foreword = "Foreword"
        case illustrator = "Illustrator"
        case translator = "Translator"
        
        public static var allNames: [String] { get { return allCases.map { $0.rawValue } } }
    }

    public class func named(_ name: StandardName, in context: NSManagedObjectContext) -> Role {
        return named(name.rawValue, in: context)
    }
    
    public class func allRoles(context: NSManagedObjectContext) -> [Role] {
        let result: [Role] = context.everyEntity(sorting: [NSSortDescriptor(key: "name", ascending: true)])
        return result
    }

     @objc public var lowercaseName: String? { return name?.lowercased() }
    
    @objc public var label: String? { return lowercaseName }
    
    @objc public var sortName: String? { return name }

    override public class func getProvider() -> DetailProvider {
        return RoleDetailProvider()
    }

}
