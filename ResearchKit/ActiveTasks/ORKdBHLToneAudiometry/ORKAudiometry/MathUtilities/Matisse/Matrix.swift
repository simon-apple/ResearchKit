//  Matrix.swift
//  Matisse 2.0 Framework
//
//  Created by Sasha Lopoukhine on 06/12/2019.
//  Copyright © 2019 Apple. All rights reserved.
//
// apple-internal
// swiftlint:disable superfluous_disable_command line_length extension_access_modifier
// swiftlint:disable superfluous_disable_command unneeded_parentheses_in_closure_argument file_length
// swiftlint:disable superfluous_disable_command identifier_name

import Accelerate

// MARK: - Matrix

@available(iOS 14, *)
public struct Matrix<Element> {

    public struct Shape: Hashable, Equatable, CustomStringConvertible {

        public var rows: Int
        public var columns: Int

        public init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
        }

        public var count: Int { rows * columns }

        public var description: String {
            "(\(rows)ˣ\(columns))"
        }
    }

    public internal(set) var elements: [Element]
    public internal(set) var shape: Shape

    public init(elements: [Element], shape: Shape) {
        self.elements = elements
        self.shape = shape
        checkShape()
    }

    public init(elements: [Element], rows: Int, columns: Int) {
        self = Matrix(
            elements: elements,
            shape: Shape(rows: rows, columns: columns)
        )
    }

    func checkShape() {
        precondition(elements.count == shape.count)
    }
}

// MARK: Rows

@available(iOS 14, *)
extension Matrix {

    public var rows: LazyMapSequence<Range<Int>, ArraySlice<Element>> {
        let rowIndexRange = 0 ..< shape.rows
        let rows = rowIndexRange.lazy.map { rowIndex -> ArraySlice<Element> in
            let start = rowIndex * self.shape.columns
            let count = self.shape.columns
            return self.elements[start ..< start + count]
        }
        return rows
    }

    public init(rows: [[Element]]) {
        guard let firstRow = rows.first else {
            self = Matrix(
                elements: [],
                shape: Shape(
                    rows: 0,
                    columns: 0
                )
            )
            return
        }
        precondition(rows.allSatisfy { $0.count == firstRow.count })
        self = Matrix(
            elements: Array(rows.joined()),
            shape: Shape(
                rows: rows.count,
                columns: firstRow.count
            )
        )
    }
}

// MARK: Indexing

@available(iOS 14, *)
extension Matrix {

    @inlinable
    public func position(row: Int, column: Int) -> Int {
        precondition(row <= shape.rows)
        precondition(column < shape.columns)
        return row * shape.columns + column
    }

    @inlinable
    public func index(position: Int) -> (row: Int, column: Int) {
        let (row, column) = position.quotientAndRemainder(dividingBy: shape.columns)
        return (row, column)
    }

    public subscript(row: Int, column: Int) -> Element {
        get {
            return elements[position(row: row, column: column)]
        }
        set {
            elements[position(row: row, column: column)] = newValue
        }
    }
}

@available(iOS 14, *)
extension Matrix where Element == Float {

    public subscript(columnIndices columnIndices: [Int]) -> Self {
        guard let max = columnIndices.max() else { return [] }
        precondition(max < shape.columns)

        let selfShape = self.shape
        let newShape = Shape(rows: selfShape.rows, columns: columnIndices.count)
        var new = Self.zeros(rows: newShape.rows, columns: newShape.columns)

        new.withUnsafeMutableBufferPointer { newBuffer in
            withUnsafeBufferPointer { selfBuffer in
                for (newColumnIndex, oldColumnIndex) in columnIndices.enumerated() {
                    cblas_scopy(
                        Int32(selfShape.rows),
                        selfBuffer.baseAddress! + oldColumnIndex,
                        Int32(selfShape.columns),
                        newBuffer.baseAddress! + newColumnIndex,
                        Int32(newShape.columns)
                    )
                }
            }
        }

        return new
    }
}

@available(iOS 14, *)
extension Matrix where Element == Double {

    public subscript(columnIndices columnIndices: [Int]) -> Self {
        guard let max = columnIndices.max() else { return [] }
        precondition(max < shape.columns)

        let selfShape = self.shape
        let newShape = Shape(rows: selfShape.rows, columns: columnIndices.count)
        var new = Self.zeros(rows: newShape.rows, columns: newShape.columns)

        new.withUnsafeMutableBufferPointer { newBuffer in
            withUnsafeBufferPointer { selfBuffer in
                for (newColumnIndex, oldColumnIndex) in columnIndices.enumerated() {
                    cblas_dcopy(
                        Int32(selfShape.rows),
                        selfBuffer.baseAddress! + oldColumnIndex,
                        Int32(selfShape.columns),
                        newBuffer.baseAddress! + newColumnIndex,
                        Int32(newShape.columns)
                    )
                }
            }
        }

        return new
    }
}

// MARK: Equatable

@available(iOS 14, *)
extension Matrix: Equatable where Element: Equatable {

    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.elements == rhs.elements
            && lhs.shape == rhs.shape
    }
}

// MARK: Hashable

@available(iOS 14, *)
extension Matrix: Hashable where Element: Hashable {

    public func hash(into hasher: inout Hasher) {
        elements.hash(into: &hasher)
        shape.hash(into: &hasher)
    }
}

// MARK: Array Literal

@available(iOS 14, *)
extension Matrix: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: [Element]...) {
        self = Matrix(rows: elements)
    }
}

// MARK: Description

@available(iOS 14, *)
extension Matrix: CustomStringConvertible {
    private func reversePadded(string: String, toLength: Int) -> String {
        return String(String(string.reversed()).padding(toLength: toLength, withPad: " ", startingAt: 0).reversed())
    }
    
    public var description: String {
        let stringsLength = elements.map { String(format: "%.8lf", $0 as? Double ?? 0.0).count }
        let maxLength = stringsLength.max() ?? 0
        
        var description = "Matrix(\(shape), [\n"
        for row in rows {
            description += row.map { reversePadded(string: String(format: "%.8lf", $0 as? Double ?? 0.0), toLength: maxLength) }.reduce("") { $0 + $1 + ", " } + "\n"
        }
        description += "]\n"
        return description
    }
}

// MARK: Initializers

@available(iOS 14, *)
extension Matrix {

    public init(repeating repeatedElement: Element, shape: Shape) {
        self = Matrix(
            elements: [Element](
                repeating: repeatedElement,
                count: shape.count
            ),
            shape: shape
        )
    }

    public init(repeating repeatedElement: Element, rows: Int, columns: Int) {
        self = Matrix(
            repeating: repeatedElement,
            shape: Shape(
                rows: rows,
                columns: columns
            )
        )
    }
}

@available(iOS 14, *)
extension Matrix where Element: ExpressibleByIntegerLiteral {

    public static func zeros(rows: Int, columns: Int) -> Matrix {
        return Matrix(repeating: 0, rows: rows, columns: columns)
    }

    public static func ones(rows: Int, columns: Int) -> Matrix {
        return Matrix(repeating: 1, rows: rows, columns: columns)
    }
}

// MARK: Appending

@available(iOS 14, *)
extension Matrix {

    public mutating func appendRow<Row: Collection>(_ row: Row) where Row.Element == Element {
        if shape.rows == 0 {
            shape.columns = row.count
        }

        precondition(row.count == shape.columns)
        
        if let vector = row as? Vector<Element> {
            // Array appends are faster than other appends
            appendRow(vector.elements)
            return
        }

        elements.append(contentsOf: row)
        shape.rows += 1
    }

    public func appendingColumn(_ vector: Vector<Element>) -> Self {
        precondition(shape.rows == vector.count)

        let shape = self.shape
        let newShape = Shape(rows: shape.rows, columns: shape.columns + 1)
        return Matrix(
            elements: [Element](unsafeUninitializedCapacity: newShape.count) { newBuffer, initializedCount in
                withUnsafeBufferPointer { selfBuffer in
                    vector.withUnsafeBufferPointer { vectorBuffer in
                        var newBase = newBuffer.baseAddress!
                        var oldBase = selfBuffer.baseAddress!
                        let vectorBase = vectorBuffer.baseAddress!
                        for row in 0 ..< newShape.rows {
                            newBase.initialize(from: oldBase, count: shape.columns)
                            newBase += shape.columns
                            oldBase += shape.columns
                            newBase.initialize(from: vectorBase + row, count: 1)
                            newBase += 1
                        }
                    }
                }
                initializedCount = newShape.count
            },
            shape: newShape
        )
    }
    
    public func appendingColumns(of matrix: Matrix) -> Self {
        let shape = self.shape
        let otherShape = matrix.shape

        precondition(otherShape.rows == shape.rows)

        let newShape = Shape(rows: shape.rows, columns: shape.columns + otherShape.columns)
        guard !elements.isEmpty else {
            return Matrix(elements: matrix.elements, shape: newShape)
        }
        guard !matrix.elements.isEmpty else {
            return Matrix(elements: elements, shape: newShape)
        }

        return Matrix(
            elements: [Element](unsafeUninitializedCapacity: newShape.count) { newBuffer, initializedCount in
                withUnsafeBufferPointer { selfBuffer in
                    matrix.withUnsafeBufferPointer { otherBuffer in
                        var newBase = newBuffer.baseAddress!
                        var oldBase = selfBuffer.baseAddress!
                        var otherBase = otherBuffer.baseAddress!
                        for _ in 0 ..< newShape.rows {
                            newBase.initialize(from: oldBase, count: shape.columns)
                            newBase += shape.columns
                            oldBase += shape.columns
                            newBase.initialize(from: otherBase, count: otherShape.columns)
                            newBase += otherShape.columns
                            otherBase += otherShape.columns
                        }
                    }
                }
                initializedCount = newShape.count
            },
            shape: newShape
        )
    }
}

// MARK: Accelerate

@available(iOS 14, *)
extension Matrix: AccelerateBufferWrapper {

    public var count: Int { elements.count }

    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        return try elements.withUnsafeMutableBufferPointer(body)
    }
}

// MARK: Accelerate

@available(iOS 14, *)
extension Matrix where Element == Double {

    public func transposed() -> Self {
        let shape = self.shape
        let elements: [Element] = Array(unsafeUninitializedCapacity: shape.count) { (newBuffer, initializedCount) in
            withUnsafeBufferPointer { selfBuffer in
                vDSP_mtransD(selfBuffer.baseAddress!, 1, newBuffer.baseAddress!, 1, vDSP_Length(shape.columns), vDSP_Length(shape.rows))
            }
            initializedCount = shape.count
        }

        return Self(elements: elements, shape: Shape(rows: shape.columns, columns: shape.rows))
    }
}

@available(iOS 14, *)
extension Matrix where Element == Float {

    public func transposed() -> Self {
        let shape = self.shape
        let elements: [Element] = Array(unsafeUninitializedCapacity: shape.count) { (newBuffer, initializedCount) in
            withUnsafeBufferPointer { selfBuffer in
                vDSP_mtrans(selfBuffer.baseAddress!, 1, newBuffer.baseAddress!, 1, vDSP_Length(shape.columns), vDSP_Length(shape.rows))
            }
            initializedCount = shape.count
        }

        return Self(elements: elements, shape: Shape(rows: shape.columns, columns: shape.rows))
    }
}

@available(iOS 14, *)
extension Matrix where Element == Double {

    public static func * (lhs: Self, rhs: Self) -> Self {
        let lhsShape = lhs.shape
        let rhsShape = rhs.shape
        let newShape = Shape(rows: lhsShape.rows, columns: rhsShape.columns)
        return Self(
            elements: lhs.withUnsafeBufferPointer { lhsBuffer in
                rhs.withUnsafeBufferPointer { rhsBuffer in
                    Array(unsafeUninitializedCapacity: newShape.count) { (newBuffer, initializedCount) in
                        cblas_dgemm(
                            CblasRowMajor,
                            CblasNoTrans,
                            CblasNoTrans,
                            Int32(lhsShape.rows),
                            Int32(rhsShape.columns),
                            Int32(lhsShape.columns),
                            1,
                            lhsBuffer.baseAddress,
                            Int32(lhsShape.columns),
                            rhsBuffer.baseAddress,
                            Int32(rhsShape.columns),
                            0,
                            newBuffer.baseAddress,
                            Int32(newShape.columns)
                        )

                        initializedCount = newShape.count
                    }
                }
            },
            shape: newShape
        )
    }
}

@available(iOS 14, *)
extension Matrix where Element == Float {

    public static func * (lhs: Self, rhs: Self) -> Self {
        let lhsShape = lhs.shape
        let rhsShape = rhs.shape
        let newShape = Shape(rows: lhsShape.rows, columns: rhsShape.columns)
        return Self(
            elements: lhs.withUnsafeBufferPointer { lhsBuffer in
                rhs.withUnsafeBufferPointer { rhsBuffer in
                    Array(unsafeUninitializedCapacity: newShape.count) { (newBuffer, initializedCount) in
                        cblas_sgemm(
                            CblasRowMajor,
                            CblasNoTrans,
                            CblasNoTrans,
                            Int32(lhsShape.rows),
                            Int32(rhsShape.columns),
                            Int32(lhsShape.columns),
                            1,
                            lhsBuffer.baseAddress,
                            Int32(lhsShape.columns),
                            rhsBuffer.baseAddress,
                            Int32(rhsShape.columns),
                            0,
                            newBuffer.baseAddress,
                            Int32(newShape.columns)
                        )

                        initializedCount = newShape.count
                    }
                }
            },
            shape: newShape
        )
    }
}

// MARK: Row & Column-wise Operations

@available(iOS 14, *)
extension MatrixAxis {

    var flipped: MatrixAxis {
        switch self {
        case .rows:
            return .columns
        case .columns:
            return .rows
        }
    }
}

@available(iOS 14, *)
extension Matrix {

    public typealias Axis = MatrixAxis

    public func number(of axis: Axis) -> Int {
        switch axis {
        case .rows:
            return shape.rows
        case .columns:
            return shape.columns
        }
    }

    public struct Slice {
        var pointer: UnsafePointer<Element>
        var stride: Int
        var count: Int
    }

    public struct MutableSlice {
        var pointer: UnsafeMutablePointer<Element>
        var stride: Int
        var count: Int
    }

    public func aggregate1<Value>(along axis: Axis, aggregation: (Slice, UnsafeMutablePointer<Value>) -> Void) -> Vector<Value> {
        let resultCount = number(of: axis)

        let sliceStartStride: Int
        let sliceStride: Int
        let sliceCount: Int

        switch axis {
        case .rows:
            sliceStartStride = shape.columns
            sliceStride = 1
            sliceCount = shape.columns
        case .columns:
            sliceStartStride = 1
            sliceStride = shape.columns
            sliceCount = shape.rows
        }

        return withUnsafeBufferPointer { buffer -> Vector<Value> in
            let matrixStart = buffer.baseAddress!

            return Vector(
                elements: Array(unsafeUninitializedCapacity: resultCount, initializingWith: { vectorBuffer, initializedCount in
                    let vectorStart = vectorBuffer.baseAddress!

                    for i in 0 ..< resultCount {
                        let slice = Slice(
                            pointer: matrixStart + i * sliceStartStride,
                            stride: sliceStride,
                            count: sliceCount
                        )

                        aggregation(slice, vectorStart + i)
                    }

                    initializedCount = resultCount
                })
            )
        }
    }

    public func aggregate2<Value0: FloatingPoint, Value1: FloatingPoint>(
        along axis: Axis,
        transform: (Slice, UnsafeMutablePointer<Value0>, UnsafeMutablePointer<Value1>) -> Void
    ) -> (Vector<Value0>, Vector<Value1>) {
        let resultCount = number(of: axis)

        let sliceStartStride: Int
        let sliceStride: Int
        let sliceCount: Int

        switch axis {
        case .rows:
            sliceStartStride = shape.columns
            sliceStride = 1
            sliceCount = shape.columns
        case .columns:
            sliceStartStride = 1
            sliceStride = shape.columns
            sliceCount = shape.rows
        }

        return withUnsafeBufferPointer { buffer -> (Vector<Value0>, Vector<Value1>) in
            var array0 = [Value0](repeating: 0, count: resultCount)
            var array1 = [Value1](repeating: 0, count: resultCount)

            array0.withUnsafeMutableBufferPointer { buffer0 in
                let array0Start = buffer0.baseAddress!

                array1.withUnsafeMutableBufferPointer { buffer1 in
                    let array1Start = buffer1.baseAddress!

                    let matrixStart = buffer.baseAddress!

                    for i in 0 ..< resultCount {
                        let slice = Slice(
                            pointer: matrixStart + i * sliceStartStride,
                            stride: sliceStride,
                            count: sliceCount
                        )

                        transform(slice, array0Start + i, array1Start + i)
                    }
                }
            }

            return (
                Vector(elements: array0),
                Vector(elements: array1)
            )
        }
    }

    public mutating func modify(along axis: Axis, transform: (MutableSlice) -> Void) {
        let resultCount = number(of: axis)

        let sliceStartStride: Int
        let sliceStride: Int
        let sliceCount: Int

        switch axis {
        case .rows:
            sliceStartStride = shape.columns
            sliceStride = 1
            sliceCount = shape.columns
        case .columns:
            sliceStartStride = 1
            sliceStride = shape.columns
            sliceCount = shape.rows
        }

        return withUnsafeMutableBufferPointer { buffer in
            let matrixStart = buffer.baseAddress!

            for i in 0 ..< resultCount {
                let slice = MutableSlice(
                    pointer: matrixStart + i * sliceStartStride,
                    stride: sliceStride,
                    count: sliceCount
                )

                transform(slice)
            }
        }
    }

    public mutating func modify<Value0: FloatingPoint, Value1: FloatingPoint>(
        along axis: Axis,
        transform: (MutableSlice, UnsafeMutablePointer<Value0>, UnsafeMutablePointer<Value1>) -> Void
    ) -> (Vector<Value0>, Vector<Value1>) {
        let resultCount = number(of: axis)

        let sliceStartStride: Int
        let sliceStride: Int
        let sliceCount: Int

        switch axis {
        case .rows:
            sliceStartStride = shape.columns
            sliceStride = 1
            sliceCount = shape.columns
        case .columns:
            sliceStartStride = 1
            sliceStride = shape.columns
            sliceCount = shape.rows
        }

        return withUnsafeMutableBufferPointer { buffer -> (Vector<Value0>, Vector<Value1>) in
            var array0 = [Value0](repeating: 0, count: resultCount)
            var array1 = [Value1](repeating: 0, count: resultCount)

            array0.withUnsafeMutableBufferPointer { buffer0 in
                let array0Start = buffer0.baseAddress!

                array1.withUnsafeMutableBufferPointer { buffer1 in
                    let array1Start = buffer1.baseAddress!

                    let matrixStart = buffer.baseAddress!

                    for i in 0 ..< resultCount {
                        let slice = MutableSlice(
                            pointer: matrixStart + i * sliceStartStride,
                            stride: sliceStride,
                            count: sliceCount
                        )

                        transform(slice, array0Start + i, array1Start + i)
                    }
                }
            }

            return (
                Vector(elements: array0),
                Vector(elements: array1)
            )
        }
    }
}

@available(iOS 14, *)
extension Matrix where Element == Float {

    public func sum(along axis: Axis) -> Vector<Element> {
        return aggregate1(along: axis) { slice, sumPointer in
            vDSP_sve(slice.pointer, slice.stride, sumPointer, vDSP_Length(slice.count))
        }
    }

    public func mean(along axis: Axis) -> Vector<Element> {
        return aggregate1(along: axis) { slice, meanPointer in
            vDSP_meanv(slice.pointer, slice.stride, meanPointer, vDSP_Length(slice.count))
        }
    }
    
    public func magnitude(along axis: Axis) -> Vector<Float> {
        return aggregate1(along: axis) { (slice, resultPointer) in
            resultPointer.pointee = cblas_snrm2(Int32(slice.count), slice.pointer, Int32(slice.stride))
        }
    }

    public func meanAndStandardDeviation(along axis: Axis) -> (means: Vector<Element>, standardDeviations: Vector<Element>) {
        return aggregate2(along: axis) { slice, meanPointer, standardDeviationPointer in
        vDSP_normalize(slice.pointer, slice.stride, nil, 1, meanPointer, standardDeviationPointer, vDSP_Length(slice.count))
        }
    }

    public mutating func normalizeMeanAndStandardDeviation(along axis: Axis) {
        modify(along: axis) { slice in
            var mean: Element = 0
            var standardDeviation: Element = 0
            vDSP_normalize(slice.pointer, slice.stride, slice.pointer, slice.stride, &mean, &standardDeviation, vDSP_Length(slice.count))
        }
    }

    public mutating func normalizeAndReturnMeanAndStandardDeviation(
        along axis: Axis
    ) -> (mean: Vector<Element>, deviation: Vector<Element>) {
        modify(along: axis) { (slice, meanPointer, standardDeviationPointer) in
            vDSP_normalize(
                slice.pointer,
                slice.stride,
                slice.pointer,
                slice.stride,
                meanPointer,
                standardDeviationPointer,
                vDSP_Length(slice.count)
            )
        }
    }
    
    public mutating func normalizeMagnitude(along axis: Axis) {
        let normVector = magnitude(along: axis)
        divide(by: normVector, along: axis)
    }
    
    public mutating func divide(by vector: Vector<Float>, along axis: Axis) {
        precondition(self.number(of: axis) == vector.count)
        var vectorIndex = 0
        modify(along: axis) { slice in
            var divisor = vector.elements[vectorIndex]
            if divisor != 0 {
                vDSP_vsdiv(
                    slice.pointer,
                    slice.stride,
                    &divisor,
                    slice.pointer,
                    slice.stride,
                    vDSP_Length(slice.count)
                )
            }
            vectorIndex += 1
        }
    }
}

@available(iOS 14, *)
extension Matrix where Element == Double {

    public func sum(along axis: Axis) -> Vector<Element> {
        return aggregate1(along: axis) { slice, sumPointer in
            vDSP_sveD(slice.pointer, slice.stride, sumPointer, vDSP_Length(slice.count))
        }
    }

    public func mean(along axis: Axis) -> Vector<Element> {
        return aggregate1(along: axis) { slice, meanPointer in
            vDSP_meanvD(slice.pointer, slice.stride, meanPointer, vDSP_Length(slice.count))
        }
    }
    
    public func magnitude(along axis: Axis) -> Vector<Double> {
        return aggregate1(along: axis) { (slice, resultPointer) in
            resultPointer.pointee = cblas_dnrm2(Int32(slice.count), slice.pointer, Int32(slice.stride))
        }
    }
    
    public mutating func divide(by vector: Vector<Double>, along axis: Axis) {
        precondition(self.number(of: axis) == vector.count)
        var vectorIndex = 0
        modify(along: axis) { slice in
            var divisor = vector.elements[vectorIndex]
            if divisor != 0 {
                vDSP_vsdivD(
                    slice.pointer,
                    slice.stride,
                    &divisor,
                    slice.pointer,
                    slice.stride,
                    vDSP_Length(slice.count)
                )
            }
            vectorIndex += 1
        }
    }
}
