// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct AnyCodable {
    
    public init(_ value: Any?) {
        self.value = value
    }
    
    public let value: Any?
}

extension AnyCodable: Decodable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if container.decodeNil() {
            self.value = nil
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "can't decode")
        }
    }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        guard let value = self.value else {
            try container.encodeNil()
            return
        }
        
        switch value {
        case let value as String:
            try container.encode(value)
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as UInt:
            try container.encode(value)
        case let value as Array<Any>:
            try container.encode(value.map { AnyCodable($0) })
        case let value as Dictionary<String, Any>:
            try container.encode(value.mapValues { AnyCodable($0) })
        case let value as Double:
            try container.encode(value)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "can't encode"))
        }
    }
}

extension AnyCodable: Equatable {

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {

        switch (lhs.value, rhs.value) {
        case (let lhs as String, let rhs as String):
            return lhs == rhs
        case (let lhs as Bool, let rhs as Bool):
            return lhs == rhs
        case (let lhs as Int, let rhs as Int):
            return lhs == rhs
        case (let lhs as UInt, let rhs as UInt):
            return lhs == rhs
        case (let lhs as Double, let rhs as Double):
            return lhs == rhs
        case (let lhs as [String: AnyCodable], let rhs as [String: AnyCodable]):
            return lhs == rhs
        case (let lhs as [AnyCodable], let rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}
