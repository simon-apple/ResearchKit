/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
// apple-internal

import Accelerate

@available(iOS 14, *)
public extension Matrix where Element == Double {
    
    func getRow(_ row: Int) -> Self {
        let rowArray = Array(rows.elements[row])
        return Matrix(elements: rowArray, rows: 1, columns: rowArray.count)
    }
    
    func getRows(_ rows: [Int]) -> Self {
        var newMatrix = Matrix(elements: [], rows: 0, columns: shape.columns)
        for row in rows {
            let rowArray = Array(self.rows[row])
            newMatrix.appendRow(rowArray)
        }
        return newMatrix
    }
    
    func getColumn(_ column: Int) -> Self {
        return self[columnIndices: [column]]
    }
    
    func pow(expoent: Element) -> Self {
        let newElements = vForce.pow(bases: self,
                                     exponents: Self(repeating: expoent, shape: shape))
        
        return Matrix(elements: newElements, shape: shape)
    }
    
    static func eye(_ size: Int) -> Self {
        return Vector(repeating: 1.0, count: size).diagonalMatrix()
    }
    
    static func exp(_ matrix: Matrix<Element>) -> Self {
        return Matrix(elements: vForce.exp(matrix), shape: matrix.shape)
    }
    
    static func log(_ matrix: Matrix<Element>) -> Self {
        return Matrix(elements: vForce.log(matrix), shape: matrix.shape)
    }
    
    static func + (lhs: Matrix<Element>, rhs: Vector<Element>) -> Matrix<Element> {
        let newElements = lhs.elements
            .map { rhs.add(scalar: $0) }
            .reduce([Element]()) { $0 + $1 }
        
        return Matrix(elements: newElements,
                      rows: lhs.shape.rows,
                      columns: rhs.count * lhs.shape.columns)
    }
}

@available(iOS 14, *)
extension Matrix {
    init(_ vector: Vector<Element>) {
        self = Matrix(elements: vector.elements, rows: 1, columns: vector.count)
    }
    
    func reshaped(rows: Int, columns: Int) -> Self {
        precondition(rows != -1 || columns != -1, "Cannot reshape with rows and columns undefined")
        
        let newShape: Shape
        if rows == -1 {
            newShape = Shape(rows: shape.count / columns, columns: columns)
        } else if columns == -1 {
            newShape = Shape(rows: rows, columns: shape.count / rows)
        } else {
            newShape = Shape(rows: rows, columns: columns)
        }

        precondition(newShape.count == shape.count)
        return Self(elements: self.elements, shape: newShape)
    }
    
    func diagonalVector() -> Vector<Element> where Element: ExpressibleByFloatLiteral {
        var diagonalArray = [Element]()
        for index in 0..<shape.rows {
            guard shape.columns >= index else {
                break
            }
            diagonalArray.append(self[index, index])
        }
        return Vector(diagonalArray)
    }
    
    func asVector() -> Vector<Element> {
        return Vector(elements: elements)
    }
}

@available(iOS 14, *)
public extension Matrix where Element == Double {
    func inv() -> Matrix<Double> {
        precondition(shape.rows == shape.columns, "Only support square matrices")
                
        let count = shape.rows * shape.columns
        var pivots = [__CLPK_integer](repeating: 0, count: count)
        var work = [CDouble](repeating: 0.0, count: count)
        var lwork = __CLPK_integer(count)
        var error = __CLPK_integer(0)
        var ncolumns = __CLPK_integer(shape.columns)
        
        var new = Matrix(elements: elements, shape: shape)
        
        new.withUnsafeMutableBufferPointer { newBuffer in
            withUnsafeMutablePointer(to: &ncolumns) { ncolumns in
                dgetrf_(ncolumns, ncolumns, newBuffer.baseAddress, ncolumns, &pivots, &error)
                dgetri_(ncolumns, newBuffer.baseAddress, ncolumns, &pivots, &work, &lwork, &error)
            }
        }
        
        assert(error == 0, "Matrix cannot be inverted")
        return new
    }
    
    func det() -> Double? {
        var pivots = [__CLPK_integer](repeating: 0, count: min(shape.rows, shape.columns))
        var error = __CLPK_integer()
        var rows = __CLPK_integer(shape.rows)
        var columns = __CLPK_integer(shape.columns)
        
        var new = Matrix(elements: elements, shape: shape)

        _ = new.withUnsafeMutableBufferPointer { newBuffer in
            withUnsafeMutablePointer(to: &rows) { rows in
                dgetrf_(rows, &columns, newBuffer.baseAddress, rows, &pivots, &error)
            }
        }

        if error != 0 {
            return nil
        }

        var determinant: Double = 1
        for (index, pivot) in zip(pivots.indices, pivots) {
            if pivot != index + 1 {
                determinant = -determinant * new[index, index]
            } else {
                determinant = determinant * new[index, index]
            }
        }
        return determinant
    }
    
    func slogdet() -> (sign: Int, determinant: Double) {
        let determinant = self.det()
        
        guard let determinant = determinant else {
            return (0, -Double.infinity)
        }
        
        let logdet = CoreGraphics.log(abs(determinant))
        
        switch determinant {
        case 0...:
            return (1, logdet)
        case ..<0:
            return (-1, logdet)
        default:
            return (0, 0.0)
        }
    }
    
    func multipliedByTransposed() -> Self {
        let newShape = Shape(rows: shape.rows, columns: shape.rows)

        return Self(
            elements: self.withUnsafeBufferPointer { buffer in
                Array(unsafeUninitializedCapacity: newShape.count) { newBuffer, initializedCount in
                    cblas_dgemm(
                        CblasRowMajor,
                        CblasNoTrans,
                        CblasTrans,
                        Int32(shape.rows),
                        Int32(shape.rows),
                        Int32(shape.columns),
                        1,
                        buffer.baseAddress,
                        Int32(shape.columns),
                        buffer.baseAddress,
                        Int32(shape.columns),
                        0,
                        newBuffer.baseAddress,
                        Int32(newShape.rows)
                    )
                    
                    initializedCount = newShape.count
                }
            },
            shape: newShape
        )
    }
}

@available(iOS 14, *)
public extension Matrix where Element == Double {
    static func mGrid(xRange: ClosedRange<Double>,
                      xSteps: Int,
                      yRange: ClosedRange<Double>,
                      ySteps: Int) -> (Matrix<Element>, Matrix<Element>) {
        let xValues = vDSP.linearInterpolate(values: [xRange.lowerBound, xRange.upperBound],
                                             atIndices: [0, Double(xSteps - 1)])
        
        var xMatrix = Matrix(elements: xValues, rows: xSteps, columns: 1)
        for _ in 1..<ySteps {
            xMatrix = xMatrix.appendingColumn(xValues.asVector())
        }
        
        let yValues = vDSP.linearInterpolate(values: [yRange.lowerBound, yRange.upperBound],
                                             atIndices: [0, Double(ySteps - 1)])
        
        var yMatrix = Matrix(elements: yValues, rows: 1, columns: ySteps)
        for _ in 1..<xSteps {
            yMatrix.appendRow(yValues)
        }
            
        return (xMatrix, yMatrix)
    }
    
    //numpy.stack of two matrices with axis=-1
    static func stack(_ matrixA: Matrix<Element>, _ matrixB: Matrix<Element>) -> [Matrix<Element>] {
        precondition(matrixA.shape == matrixB.shape)
        
        var grid = [Matrix<Element>]()
        for index in 0..<matrixA.shape.rows {
            let rowA = Array(matrixA.rows.elements[index])
            let rowB = Array(matrixB.rows.elements[index])
            var matrix = Matrix(elements: rowA, rows: rowA.count, columns: 1)
            matrix = matrix.appendingColumn(rowB.asVector())
            grid.append(matrix)
        }
        
        return grid
    }
    
    mutating func appendRows(of matrix: Matrix<Element>) {
        for index in 0..<matrix.shape.rows {
            let row = Array(matrix.rows.elements[index])
            appendRow(row)
        }
    }
    
    static func reshape2columns(_ matrices: [Matrix<Element>]) -> Matrix<Element> {
        precondition(!matrices.isEmpty)

        var newMatrix = Matrix(elements: [], rows: 0, columns: matrices[0].shape.columns)
        for matrix in matrices {
            newMatrix.appendRows(of: matrix)
        }
        return newMatrix
    }
}

@available(iOS 14, *)
public extension Matrix where Element == Double {
    func sorted(byColumn: Int, ascending: Bool = true) -> Matrix<Element> {
        precondition(byColumn < shape.columns)
        
        var indices = Array(0..<shape.rows).map { vDSP_Length($0) }
        var values = getColumn(byColumn).elements
        let order: Int32 = ascending ? 1 : -1
        
        withUnsafeMutablePointer(to: &indices[0]) { unsafeIndices in
            withUnsafePointer(to: &values[0]) { unsafeValues in
                vDSP_vsortiD(unsafeValues, unsafeIndices, nil, vDSP_Length(shape.rows), order)
            }
        }
  
        var sortedMatrix = Matrix<Element>(elements: [], rows: 0, columns: shape.columns)
        for rowIdx in 0..<shape.rows {
            let row = getRow(Int(indices[rowIdx]))
            sortedMatrix.appendRow(row.elements)
        }
        
        return sortedMatrix
    }
    
    func filterOnColumn(_ column: Int, by condition: (Element) -> Bool) -> Matrix<Element> {
        precondition(column < shape.columns)

        var newMatrix = Matrix<Double>(elements: [], rows: 0, columns: shape.columns)
        for rowSlice in rows {
            let row = Array(rowSlice)
            if condition(row[column]) {
                newMatrix.appendRow(row)
            }
        }

        return newMatrix
    }
    
    func gatherRows(_ rows: [Int]) -> Matrix<Element> {
        precondition(rows.count <= shape.rows)
        guard rows != Array(0..<shape.rows) else {
            return self
        }

        var newMatrix = Matrix<Double>(elements: [], rows: 0, columns: shape.columns)
        for rowIdx in rows {
            let row = Array(self.rows[rowIdx])
            newMatrix.appendRow(row)
        }

        return newMatrix
    }
    
    func filterRows(_ rows: [Int]) -> Matrix<Element> {
        precondition(rows.count <= shape.rows)
        guard !rows.isEmpty else {
            return self
        }
        
        var newMatrix = Matrix<Double>(elements: [], rows: 0, columns: shape.columns)
        for rowIdx in 0..<shape.rows {
            if !rows.contains(rowIdx) {
                let row = Array(self.rows[rowIdx])
                newMatrix.appendRow(row)
            }
        }

        return newMatrix
    }
    
    mutating func clip(to range: ClosedRange<Double>, along axis: Axis, withIndex index: Int) {
        precondition(self.number(of: axis) > index)
        
        var idx = 0
        modify(along: axis) { slice in
            if index == idx {
                var lowerBound = range.lowerBound
                var upperBound = range.upperBound
                vDSP_vclipD(
                    slice.pointer,
                    slice.stride,
                    &lowerBound,
                    &upperBound,
                    slice.pointer,
                    slice.stride,
                    vDSP_Length(slice.count)
                )
            }
            idx += 1
        }
    }
    
    mutating func addInplace(_ element: Element) {
        let axis: MatrixAxis = shape.rows > shape.columns ? .columns : .rows
        
        modify(along: axis) { slice in
            var scalar = element
            vDSP_vsaddD(
                slice.pointer,
                slice.stride,
                &scalar,
                slice.pointer,
                slice.stride,
                vDSP_Length(slice.count)
            )
        }
    }
    
    static func allClose(_ lhs: Matrix<Element>, _ rhs: Matrix<Element>, atol: Element) -> Bool {
        return zip(lhs.elements, rhs.elements).allSatisfy { abs($0 - $1) <= atol }
    }
}
