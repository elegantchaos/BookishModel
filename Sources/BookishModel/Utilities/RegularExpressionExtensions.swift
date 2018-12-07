// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol RegularExpressionResult {
    init()
}
//
//extension RegularExpressionResult {
//    func make() -> RegularExpressionResult {
//        return RegularExpressionResult()
//    }
//}

//protocol RegularExpressionResult: ExpressibleByNilLiteral {
//}
//
//extension RegularExpressionResult {
//    init(nilLiteral: ()) {
//    }
//}
//
//protocol RegularExpressionResult: ExpressibleByDictionaryLiteral where Key == PartialKeyPath<Self>, Value == String {
//}
//
//extension RegularExpressionResult where Key == PartialKeyPath<Self>, Value == String {
//    init(dictionaryLiteral elements: (PartialKeyPath<Self>, String)...) {
////            self.init()
//    }
//    typealias InitDictionary = [Key:Value]
//
//    init(dictionaryLiteral elements: (PartialKeyPath<Self>, String)...) {
//        self.init()
//        for element in elements {
//            let key = element.0
//            let value = element.1
//            if let path = key as? WritableKeyPath<Self, String> {
//                self[keyPath: path] = value
//            } else if let path = key as? WritableKeyPath<Self, Int> {
//                self[keyPath: path] = (value as NSString).integerValue
//            }
//        }
//    }
//
//    static func setup(dictionaryLiteral elements: (PartialKeyPath<Self>, String)...) {
//        for element in elements {
//            let key = element.0
//            let value = element.1
//            if let path = key as? WritableKeyPath<Self, String> {
//                self[keyPath: path] = value
//            } else if let path = key as? WritableKeyPath<Self, Int> {
//                self[keyPath: path] = (value as NSString).integerValue
//            }
//        }
//    }

//}


//protocol RegularExpressionResult: ExpressibleByDictionaryLiteral where Key == PartialKeyPath<Self>, Value == String {
//}
//
//extension RegularExpressionResult where Key == PartialKeyPath<Self>, Value == String {
//    typealias InitDictionary = [Key:Value]
//
//    init(dictionaryLiteral elements: (PartialKeyPath<Self>, String)...) {
//        self.init()
//        for element in elements {
//            let key = element.0
//            let value = element.1
//            if let path = key as? WritableKeyPath<Self, String> {
//                self[keyPath: path] = value
//            } else if let path = key as? WritableKeyPath<Self, Int> {
//                self[keyPath: path] = (value as NSString).integerValue
//            }
//        }
//    }
//}

//
//protocol RegularExpressionResult2 {
//}
//
//extension RegularExpressionResult2 {
//    static func make() -> RegularExpressionResult2 {
//        return RegularExpressionResult2()
//    }
////
////    typealias InitDictionary = [PartialKeyPath<Self>:String]
////    init(matchesdictionaryLiteral elements: InitDictionary) {
////        for element in elements {
////            let key = element.0
////            let value = element.1
////            if let path = key as? WritableKeyPath<Self, String> {
////                self[keyPath: path] = value
////            } else if let path = key as? WritableKeyPath<Self, Int> {
////                self[keyPath: path] = (value as NSString).integerValue
////            }
////        }
////    }
//}

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

    func firstMatch2<T: RegularExpressionResult>(of string: String, mappings: [PartialKeyPath<T>:Int]) -> T? {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            var result = T()
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    if let path = mapping.key as? WritableKeyPath<T,String> {
                        result[keyPath: path] = String(string[range])
                    } else if let path = mapping.key as? WritableKeyPath<T,Int> {
                        result[keyPath: path] = (String(string[range]) as NSString).integerValue
                    }
                }
            }
            return result
        }
        return nil
//        let range = NSRange(location: 0, length: string.count)
//        if let match = firstMatch(in: string, options: [], range: range) {
//            var extracted = T.InitDictionary()
//            for mapping in mappings {
//                if let range = Range(match.range(at: mapping.value), in: string) {
//                    extracted[mapping.key] = String(string[range])
//                }
//            }
//
//            let result : T = [:]
//            return result
//        }
//
//        return nil
    }

    func firstMatch2<T>(of string: String, mappings: [AnyHashable:Int], capture: inout T) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        if let match = firstMatch(in: string, options: [], range: range) {
            for mapping in mappings {
                if let range = Range(match.range(at: mapping.value), in: string) {
                    if let path = mapping.key as? ReferenceWritableKeyPath<T,String> {
                        capture[keyPath: path] = String(string[range])
                    } else if let path = mapping.key as? ReferenceWritableKeyPath<T,Int> {
                        capture[keyPath: path] = (String(string[range]) as NSString).integerValue
                    }
                }
            }
            return true
        }
        
        return false
    }

}
