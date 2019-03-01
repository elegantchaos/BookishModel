// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let checkCharacters = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 88]
    
    var isISBN10: Bool {
        guard self.count == 10 else {
            return false
        }

        guard let chars = self.cString(using: .ascii) else {
            return false
        }

        let zeroChar = Int8(48)
        var sum = 0
        var n = 10
        for c in chars[..<9] {
            let digit = c - zeroChar
            sum += n * Int(digit)
            n -= 1
        }
        
        let calculatedChecksum = String.checkCharacters[11 - (sum % 11)]
        let existingChecksum = chars[9]
        
        return calculatedChecksum == existingChecksum
    }

    var isISBN13: Bool {
        return self.count == 10
    }

    var checksumISBN10: Character {
        return "0"
    }

    var checksumISBN13: Character {
        return "0"
    }

}
