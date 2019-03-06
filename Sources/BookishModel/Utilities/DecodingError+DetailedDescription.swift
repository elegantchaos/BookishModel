// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension DecodingError.Context {
    
    /**
     Returns a more detailed description of the decoding error.
     
     We attempt to include the line in which the error occurred.
    */
    
    public func detailedDescription(for data: Data, window: Int = 2) -> String {
        var detail = debugDescription
        if codingPath.count > 0 {
            detail += codingPath.description
        }
        if let underlyingError = underlyingError {
            let underlyingNS = underlyingError as NSError
            if let description = underlyingNS.userInfo[NSDebugDescriptionErrorKey] as? String {
                if let range = description.range(of: "character ") {
                    var position = description[range.upperBound...]
                    position.removeLast()
                    if let i = Int(position), let json = String(data: data, encoding: .utf8) {
                        let index = json.index(json.startIndex, offsetBy: i)
                        let start = json.range(of: "\n", options: .backwards, range: Range(uncheckedBounds: (json.startIndex, index)))?.lowerBound ?? json.startIndex
                        let end = json.range(of: "\n", options: [], range: Range(uncheckedBounds: (index, json.endIndex)))?.upperBound ?? json.endIndex
                        let line = json[start...end]
                        detail += "\n\(description)\n\n"
//                        detail += "\n\(line)"
                        
                        let lineNo = json[...index].count(where: { $0 == "\n" } )
//                        detail += "\n line: \(lineNo)"
                        
                        let lines = json.split(separator: "\n")
                        let lineCount = lines.count
                        let from = lineNo > window ? lineNo - window : 0
                        let to = lineNo + window < lineCount ? lineNo + window : lineCount
                        let excerpt = lines[from...to]
                        
                        for n in from...to {
                            detail += "\(n): \(lines[n])\n"
                        }
                    }
                }
            }
        }
        return detail
    }
        
}
