// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let checkDigits: [Int8] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 88]

    static func checkDigitISBN10(for chars: ArraySlice<CChar>) -> Int8 {
        assert(chars.count == 9)

        let zeroChar = 48
        var sum = 0
        var t = 0
        for c in chars {
            let digit: Int
            switch c {
            case 88:
                digit = 10
            case 48...57:
                digit = Int(c) - zeroChar
            default:
                return -1
            }
            t += digit
            sum += t
        }
        
        sum += t
        let calculatedChecksum = String.checkDigits[11 - (sum % 11)]
        return Int8(calculatedChecksum)
    }
    
    var isISBN10: Bool {
        guard self.count == 10, let chars = self.cString(using: .ascii) else {
            return false
        }

        let range = chars[..<9]
        let calculatedDigit = String.checkDigitISBN10(for: range)
        let existingDigit = chars[9]
        
        return calculatedDigit == existingDigit
    }

    var isISBN13: Bool {
        return self.count == 10
    }

}
