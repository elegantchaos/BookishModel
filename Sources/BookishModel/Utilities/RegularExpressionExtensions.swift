// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol ResultStructure {
    static func make() -> ResultStructure
}

extension NSRegularExpression {
    func firstMatch(of string: String, mappings: [String:Int]) -> [String:String]? {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            var extracted: [String:String] = [:]
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    extracted[mapping.key] = String(string[range])
                }
            }
            return extracted
        }
        
        return nil
    }

    func firstMatchX<T: ResultStructure>(of string: String, mappings: [ReferenceWritableKeyPath<T,String>:Int]) -> T? {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            let extracted = T.make() as! T
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    extracted[keyPath: mapping.key] = String(string[range])
                }
            }
            return extracted
        }
        
        return nil
    }

}
