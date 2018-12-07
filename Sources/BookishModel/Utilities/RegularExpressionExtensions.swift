// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol RegularExpressionResult: ExpressibleByNilLiteral {
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

    func firstMatch<T: RegularExpressionResult>(of string: String, mappings: [WritableKeyPath<T,String>:Int]) -> T? {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            var extracted : T = nil
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    extracted[keyPath: mapping.key] = String(string[range])
                }
            }
            return extracted
        }
        
        return nil
    }

    func firstMatch2<T>(of string: String, mappings: [ReferenceWritableKeyPath<T,String>:Int], capture: inout T) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    capture[keyPath: mapping.key] = String(string[range])
                }
            }
            return true
        }
        
        return false
    }

}
