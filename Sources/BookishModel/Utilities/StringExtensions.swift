// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class StringLocalization {
    static var bundlesToSearch: [Bundle] = [Bundle.main]
    
    public class func registerLocalizationBundle(_ bundle: Bundle) {
        bundlesToSearch.append(bundle)
    }
}

extension String {
    
    /**
     Look up a simple localized version of the string, using the default search strategy.
     */
    
    public var localized: String {
        return localized(with: [:])
    }
    
    /**
     Look up a localized version of the string.
     If a bundle is specified, we only search there.
     If no bundle is specified, we search in a set of registered bundles.
     This always includes the main bundle, but can have other bundles added to it, allowing you
     to automatically pick up translations from framework bundles (without having to search through
     every loaded bundle).
    */
    
    public func localized(with args: [String:Any], tableName: String? = nil, bundle: Bundle? = nil, value: String = "", comment: String = "") -> String {
        var string = self
        let bundlesToSearch = bundle == nil ? StringLocalization.bundlesToSearch : [bundle!]
        
        for bundle in bundlesToSearch {
            string = NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment)
            if string != self {
                break
            }
        }
        
        for (key, value) in args {
            string = string.replacingOccurrences(of: "{\(key)}", with: String(describing: value))
        }
        return string
    }

}
