// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let checkDigits: [CChar] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 88]
    static let zeroChar = 48

    /**
     Given a slice of 9 ascii digits, returns the calculated
     ISBN-10 checksum for them.
 
     Returns -1 if it encounters a non-digit.
    */
    
    static func checkDigitISBN10(for chars: ArraySlice<CChar>) -> CChar {
        assert(chars.count == 9)

        var sum = 0
        var t = 0
        for c in chars {
            let digit: Int
            switch c {
            case 48...57:
                digit = Int(c) - String.zeroChar
            default:
                return -1
            }
            t += digit
            sum += t
        }
        
        sum += t
        let index = (11 - (sum % 11)) % 11
        let calculatedDigit = String.checkDigits[index]
        return Int8(calculatedDigit)
    }
    
    /**
     Given a slice of 12 ascii digits, returns the calculated
     ISBN-13 checksum for them.
     
     Returns -1 if it encounters a non-digit.
     */
    
    static func checkDigitISBN13(for chars: ArraySlice<CChar>) -> CChar {
        assert(chars.count == 12)
        
        var sum = 0
        var weight = 1
        for c in chars {
            let digit: Int
            switch c {
            case 48...57:
                digit = Int(c) - String.zeroChar
            default:
                return -1
            }
            sum += digit * weight
            weight = 4 - weight
        }
        
        let index = (10 - (sum % 10)) % 10
        let calculatedDigit = String.checkDigits[index]
        return Int8(calculatedDigit)
    }
    
    /**
     Is this string a valid ISBN-10 code?
    */
    
    var isISBN10: Bool {
        guard self.count == 10, let chars = self.cString(using: .ascii) else {
            return false
        }

        let calculatedDigit = String.checkDigitISBN10(for: chars[...8])
        let existingDigit = chars[9]
        
        return calculatedDigit == existingDigit
    }

    /**
     Is this string a valid ISBN-13 code?
     */

    var isISBN13: Bool {
        guard self.count == 13, let chars = self.cString(using: .ascii) else {
            return false
        }
        
        let calculatedDigit = String.checkDigitISBN13(for: chars[...11])
        let existingDigit = chars[12]
        
        return calculatedDigit == existingDigit
    }

}
