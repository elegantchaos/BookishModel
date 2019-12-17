// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/08/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore

public typealias Role = EntityType

extension Role {
    public enum StandardName: String, CaseIterable {
        case author = "Author"
        case contributor = "Contributor"
        case editor = "Editor"
        case foreword = "Foreword"
        case illustrator = "Illustrator"
        case translator = "Translator"

        public static var allNames: [String] { get { return allCases.map { $0.rawValue } } }

        public var identifier: String { return "standard-\(rawValue)" }
    }

}

//public class Role: ModelEntity, ModelEntityCommon {
//    public enum StandardName: String, CaseIterable {
//        case author = "Author"
//        case contributor = "Contributor"
//        case editor = "Editor"
//        case foreword = "Foreword"
//        case illustrator = "Illustrator"
//        case translator = "Translator"
//
//        public static var allNames: [String] { get { return allCases.map { $0.rawValue } } }
//
//        public var identifier: String { return "standard-\(rawValue)" }
//    }
//
//    public class func named(_ name: StandardName, in context: NSManagedObjectContext) -> Role {
//        return named(name.rawValue, in: context)
//    }
//
//    public class func allRoles(context: NSManagedObjectContext) -> [Role] {
//        let result: [Role] = self.everyEntity(in: context, sorting: [NSSortDescriptor(key: "name", ascending: true)])
//        return result
//    }
//
//     @objc public var lowercaseName: String? { return name?.lowercased() }
//
//    @objc public var label: String? { return lowercaseName }
//
//    @objc public var sortName: String? { return name }
//
//    @objc dynamic var sectionName: String? {
//        return Indexing.sectionName(for: sortName)
//    }
//
//    public override var summary: String? {
//        return notes
//    }
//
//    override public class func getProvider() -> DetailProvider {
//        return RoleDetailProvider()
//    }
//
//    public func relationships(sortedBy sort: [NSSortDescriptor]) -> [Relationship] {
//        return relationshipsR?.sortedArray(using: sort) as! [Relationship]
//    }
//}
