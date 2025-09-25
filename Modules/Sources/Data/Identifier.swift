//
//  Identifier.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Foundation

public struct Identifier<Parent, RawType> {
    public let rawValue: RawType
    
    public init(_ rawValue: RawType) {
        self.rawValue = rawValue
    }
}

public extension Identifier where RawType == UUID {
    static var new: Self { Self(UUID()) }
}

// MARK: Equatable & Hashable

extension Identifier: Equatable where RawType: Equatable {}
extension Identifier: Hashable where RawType: Hashable {}
extension Identifier: Sendable where RawType: Sendable {}


// MARK: Codable

extension Identifier: Encodable where RawType: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container: SingleValueEncodingContainer = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Identifier: Decodable where RawType: Decodable {
    public init(from decoder: any Decoder) throws {
        let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
        self.rawValue = try container.decode(RawType.self)
    }
}


// MARK: Comparable

extension Identifier: Comparable where RawType: Comparable {
    public static func < (lhs: Identifier<Parent, RawType>, rhs: Identifier<Parent, RawType>) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


// MARK: Custom String Convertible

extension Identifier: CustomStringConvertible where RawType: CustomStringConvertible {
    public var description: String {
        rawValue.description
    }
}

extension Identifier: CustomDebugStringConvertible where RawType: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Identifier(\(rawValue.debugDescription))"
    }
}


// MARK: Expressible by Literals

extension Identifier: ExpressibleByIntegerLiteral
    where RawType: ExpressibleByIntegerLiteral, IntegerLiteralType == RawType.IntegerLiteralType
{
    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = RawType(integerLiteral: value)
    }
}

extension Identifier: ExpressibleByUnicodeScalarLiteral where RawType == String {
    public init(unicodeScalarLiteral value: String) {
        self.rawValue = value
    }
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where RawType == String {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.rawValue = value
    }
}

extension Identifier: ExpressibleByStringLiteral where RawType == String {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}
