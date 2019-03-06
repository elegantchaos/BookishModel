// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension DecodingError.Context {
    
    /**
     Returns a more detailed description of the decoding error.
     
     We attempt to include the lines around the error.
     
     The line itself is highlighted with ←
     and the error character with ↑
     
     (the accuracy of this is dependant on the character mentioned in the underlying error)

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
                        let offsetInLine = json.distance(from: start, to: index)
                        detail += "\n\(description)\n\n"
                        
                        let lineNo = json[...index].count(where: { $0 == "\n" } )
                        
                        let lines = json.split(separator: "\n")
                        let lineCount = lines.count
                        let from = lineNo > window ? lineNo - window : 0
                        let to = lineNo + window < lineCount ? lineNo + window : lineCount
                        
                        for n in from...to {
                            let isLine = n == lineNo
                            let sep = isLine ? ":→" : ": " 
                            detail += "\n\(n)\(sep)\(lines[n])"
                            if isLine {
                                detail += " ←"
                                var indent = "\n\(n):"
                                for _ in 0 ..< offsetInLine {
                                    indent += " "
                                }
                                detail += "\(indent)↑"
                            }
                        }
                        
                        detail += "\n"
                    }
                }
            }
        }
        return detail
    }
        
}