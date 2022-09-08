//  Vector.swift
//  Matisse 2.0 Framework
//
//  Created by Sasha Lopoukhine on 04/12/2019.
//  Copyright © 2019 Apple. All rights reserved.
//
// apple-internal
// swiftlint:disable superfluous_disable_command line_length extension_access_modifier
// swiftlint:disable superfluous_disable_command identifier_name empty_count

import Accelerate

// MARK: - Vector

@available(iOS 14, *)
public struct Vector<Element> {

    public var elements: [Element]

    public init(elements: [Element]) {
        self.elements = elements
    }
}

// MARK: Equatable

@available(iOS 14, *)
extension Vector: Equatable where Element: Equatable {

    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.elements == rhs.elements
    }
}

// MARK: Hashable

@available(iOS 14, *)
extension Vector: Hashable where Element: Hashable {

    public func hash(into hasher: inout Hasher) {
        elements.hash(into: &hasher)
    }
}

// MARK: Array Literal

@available(iOS 14, *)
extension Vector: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Element...) {
        self = Vector(elements: elements)
    }
}

// MARK: Description

@available(iOS 14, *)
extension Vector: CustomStringConvertible {

    public var description: String {
        return elements.description
    }
}

@available(iOS 14, *)
extension Vector: CustomDebugStringConvertible {

    public var debugDescription: String {
        return elements.debugDescription
    }
}

// MARK: Initializers

@available(iOS 14, *)
extension Vector {

    public init<Elements: Sequence>(_ elements: Elements) where Elements.Element == Element {
        self.elements = Array(elements)
    }

    public init(repeating repeatElement: Element, count: Int) {
        self.elements = Array(repeating: repeatElement, count: count)
    }

    public init(pointer: UnsafePointer<Element>, count: Int) {
        let buffer = UnsafeBufferPointer(start: pointer, count: count)
        self.elements = Array(buffer)
    }
}

@available(iOS 14, *)
extension Vector where Element: ExpressibleByIntegerLiteral {

    public static func zeros(count: Int) -> Vector {
        return Vector(repeating: 0, count: count)
    }

    public static func ones(count: Int) -> Vector {
        return Vector(repeating: 1, count: count)
    }
}

// MARK: Accelerate

@available(iOS 14, *)
extension Vector: AccelerateBufferWrapper {

    public var count: Int { elements.count }

    public var shape: Int { elements.count }

    public init(elements: [Element], shape: Int) {
        self.elements = elements
        precondition(shape == self.shape)
    }

    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        return try elements.withUnsafeMutableBufferPointer(body)
    }
}

// MARK: Numeric

@available(iOS 14, *)
extension Vector where Element: Numeric {

    public static func *= (lhs: inout Self, factor: Element) {
        lhs.elements = lhs.elements.map { $0 * factor }
    }
}

// MARK: Dot Product

@available(iOS 14, *)
extension Vector where Element == Float {

    public static func * (lhs: Vector, rhs: Vector) -> Element {
        return vDSP.dot(lhs, rhs)
    }
}

@available(iOS 14, *)
extension Vector where Element == Double {

    public static func * (lhs: Vector, rhs: Vector) -> Element {
        return vDSP.dot(lhs, rhs)
    }
}

// MARK: Collection

@available(iOS 14, *)
extension Vector: RandomAccessCollection {

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    public subscript(position: Int) -> Element {
        get {
            return elements[position]
        }
        set {
            elements[position] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return elements.index(i, offsetBy: distance)
    }

    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        return elements.index(i, offsetBy: distance, limitedBy: limit)
    }
}
