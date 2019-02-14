// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(with args: [String:Any], tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String = "") -> String {
        var format = NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment)
        for (key, value) in args {
            format = format.replacingOccurrences(of: "{\(key)}", with: String(describing: value))
        }
        return format
    }

}
