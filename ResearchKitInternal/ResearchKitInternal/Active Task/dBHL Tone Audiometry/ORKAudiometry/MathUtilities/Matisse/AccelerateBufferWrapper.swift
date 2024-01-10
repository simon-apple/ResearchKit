//  AccelerateBufferWrapper.swift
//  Matisse 2.0 Framework
//
//  Created by Sasha Lopoukhine on 05/12/2019.
//  Copyright © 2019 Apple. All rights reserved.
//
// apple-internal
// swiftlint:disable superfluous_disable_command line_length static_operator file_length
// swiftlint:disable superfluous_disable_command identifier_name extension_access_modifier

import Accelerate

/**
 * **When adding operators, don't forget to add both the `Float` and `Double` variants.**
 */

/// Wrapper of an accelerated buffer
@available(iOS 14, *)
public protocol AccelerateBufferWrapper: AccelerateMutableBuffer {

    associatedtype Shape: Equatable

    var shape: Shape { get }
    var elements: [Element] { get }

    init(elements: [Element], shape: Shape)
}

// MARK: - General Extensions

@available(iOS 14, *)
extension AccelerateBufferWrapper {

    public func test(function: (Element) -> Bool) -> [Bool] {
        return elements.map(function)
    }
}

// MARK: AccelerateMutableBuffer

@available(iOS 14, *)
extension AccelerateBufferWrapper {

    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        return try elements.withUnsafeBufferPointer(body)
    }

    public mutating func applyMask(mask: [Bool], maskValues: Self) {
        precondition(mask.count == count)
        precondition(maskValues.shape == shape)

        withUnsafeMutableBufferPointer { selfBuffer in
            maskValues.withUnsafeBufferPointer { maskBuffer in
                for (i, shouldMask) in mask.enumerated() where shouldMask {
                    selfBuffer[i] = maskBuffer[i]
                }
            }
        }
    }

    public func masked(mask: [Bool], maskValues: Self) -> Self {
        var copy = self
        copy.applyMask(mask: mask, maskValues: maskValues)
        return copy
    }
}

precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

infix operator .**: ExponentiationPrecedence
infix operator .**=: AssignmentPrecedence

infix operator .*: MultiplicationPrecedence
infix operator .*=: AssignmentPrecedence

// MARK: - Float

func ** (lhs: Float, rhs: Float) -> Float {
    return pow(lhs, rhs)
}

func **= (lhs: inout Float, rhs: Float) {
    lhs = lhs ** rhs
}

@available(iOS 14, *)
extension AccelerateBufferWrapper where Element == Float {

    public func minimum() -> Element {
        vDSP.minimum(self)
    }
    
    public func maximum() -> Element {
        vDSP.maximum(self)
    }
    
    public func sum() -> Element {
        vDSP.sum(self)
    }

    public func sumOfSquares() -> Element {
        vDSP.sumOfSquares(self)
    }

    public func mean() -> Element {
        vDSP.mean(self)
    }

    public static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    public static func .**= (lhs: inout Self, rhs: Element) {
        var size = Int32(lhs.count)
        var exponent = rhs

        lhs.withUnsafeMutableBufferPointer { bufferPointer in
            let pointer = bufferPointer.baseAddress!
            vvpowsf(pointer, &exponent, pointer, &size)
        }
    }

    public static func .* (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.multiply(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func .** (lhs: Self, rhs: Element) -> Self {
        var copy = lhs
        copy .**= rhs
        return copy
    }

    /// The new population mean and standard deviation will be `(0, 1)`.
    /// Returns the old mean and standard deviation
    @discardableResult
    public mutating func normalize() -> (mean: Element, deviation: Element) {
        let count = vDSP_Length(self.count)
        var mean: Element = 0
        var deviation: Element = 1

        withUnsafeMutableBufferPointer { srcBuf in
            vDSP_normalize(srcBuf.baseAddress!, 1, srcBuf.baseAddress!, 1, &mean, &deviation, count)
        }

        return (mean, deviation)
    }

    public func meanAndStandardDeviation() -> (mean: Element, deviation: Element) {
        var mean: Element = 0
        var deviation: Element = 0

        withUnsafeBufferPointer { srcBuf in
            vDSP_normalize(srcBuf.baseAddress!, 1, nil, 1, &mean, &deviation, vDSP_Length(self.count))
        }

        return (mean, deviation)
    }

    public func standardDeviation() -> Element {
        return meanAndStandardDeviation().deviation
    }

    public static prefix func - (wrapper: Self) -> Self {
        return Self(
            elements: vDSP.negative(wrapper),
            shape: wrapper.shape
        )
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.subtract(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.add(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func - (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.add(-rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func - (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.add(lhs, -rhs),
            shape: rhs.shape
        )
    }

    public static func + (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.add(lhs, rhs),
            shape: rhs.shape
        )
    }

    public static func + (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.add(rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func * (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.multiply(rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func * (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.multiply(lhs, rhs),
            shape: rhs.shape
        )
    }

    public static func / (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.divide(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        precondition(lhs.shape == rhs.shape)
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        precondition(lhs.shape == rhs.shape)
        vDSP.add(lhs, rhs, result: &lhs)
    }

    public static func -= (lhs: inout Self, rhs: Element) {
        vDSP.add(-rhs, lhs, result: &lhs)
    }

    public static func += (lhs: inout Self, rhs: Element) {
        vDSP.add(rhs, lhs, result: &lhs)
    }

    public static func *= (lhs: inout Self, rhs: Element) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    public static func /= (lhs: inout Self, rhs: Element) {
        vDSP.divide(lhs, rhs, result: &lhs)
    }

    public func naturalLogarithm() -> Self {
        return Self(
            elements: self.elements.map(log),
            shape: self.shape
        )
    }
    
    public static func ** (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: rhs.elements.map { pow(lhs, $0) },
            shape: rhs.shape
        )
    }
}

// MARK: - Double

func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

func **= (lhs: inout Double, rhs: Double) {
    lhs = lhs ** rhs
}

@available(iOS 14, *)
extension AccelerateBufferWrapper where Element == Double {

    public func minimum() -> Element {
        vDSP.minimum(self)
    }
    
    public func maximum() -> Element {
        vDSP.maximum(self)
    }
    
    public func sum() -> Element {
        vDSP.sum(self)
    }

    public func sumOfSquares() -> Element {
        vDSP.sumOfSquares(self)
    }

    public func mean() -> Element {
        vDSP.mean(self)
    }

    public static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    public static func .**= (lhs: inout Self, rhs: Element) {
        var size = Int32(lhs.count)
        var exponent = rhs

        lhs.withUnsafeMutableBufferPointer { bufferPointer in
            let pointer = bufferPointer.baseAddress!
            vvpows(pointer, &exponent, pointer, &size)
        }
    }

    public static func .* (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.multiply(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func .** (lhs: Self, rhs: Element) -> Self {
        var copy = lhs
        copy .**= rhs
        return copy
    }

    public func meanAndStandardDeviation() -> (mean: Element, deviation: Element) {
        var mean: Element = 0
        var deviation: Element = 0

        withUnsafeBufferPointer { srcBuf in
            vDSP_normalizeD(srcBuf.baseAddress!, 1, nil, 1, &mean, &deviation, vDSP_Length(self.count))
        }

        return (mean, deviation)
    }

    public func standardDeviation() -> Element {
        return meanAndStandardDeviation().deviation
    }

    public static prefix func - (wrapper: Self) -> Self {
        return Self(
            elements: vDSP.negative(wrapper),
            shape: wrapper.shape
        )
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.subtract(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        precondition(lhs.shape == rhs.shape)
        return Self(
            elements: vDSP.add(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func - (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.add(-rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func - (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.add(lhs, -rhs),
            shape: rhs.shape
        )
    }

    public static func + (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.add(lhs, rhs),
            shape: rhs.shape
        )
    }

    public static func + (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.add(rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func * (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.multiply(rhs, lhs),
            shape: lhs.shape
        )
    }

    public static func * (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: vDSP.multiply(lhs, rhs),
            shape: rhs.shape
        )
    }

    public static func / (lhs: Self, rhs: Element) -> Self {
        return Self(
            elements: vDSP.divide(lhs, rhs),
            shape: lhs.shape
        )
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        precondition(lhs.shape == rhs.shape)
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        precondition(lhs.shape == rhs.shape)
        vDSP.add(lhs, rhs, result: &lhs)
    }

    public static func -= (lhs: inout Self, rhs: Element) {
        vDSP.add(-rhs, lhs, result: &lhs)
    }

    public static func += (lhs: inout Self, rhs: Element) {
        vDSP.add(rhs, lhs, result: &lhs)
    }

    public static func *= (lhs: inout Self, rhs: Element) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    public static func /= (lhs: inout Self, rhs: Element) {
        vDSP.divide(lhs, rhs, result: &lhs)
    }

    public func naturalLogarithm() -> Self {
        return Self(
            elements: self.elements.map(log),
            shape: self.shape
        )
    }
    
    public static func ** (lhs: Element, rhs: Self) -> Self {
        return Self(
            elements: rhs.elements.map { pow(lhs, $0) },
            shape: rhs.shape
        )
    }
}
