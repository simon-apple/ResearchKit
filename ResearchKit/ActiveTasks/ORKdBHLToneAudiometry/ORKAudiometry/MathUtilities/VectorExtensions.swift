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
public extension Vector where Element == Double {
    func pow(expoent: Element) -> Self {
        return Vector(elements: vForce.pow(bases: self,
                                           exponents: Self(repeating: expoent, count: count)))
    }
    
    func add(scalar: Element) -> Self {
        return Vector(elements: vDSP.add(scalar, self))
    }
    
    func indexOfMaximum() -> (index: Int, element: Element) {
        let indexMax = vDSP.indexOfMaximum(elements)
        return (Int(indexMax.0), indexMax.1)
    }
    
    func indexOfMinimum() -> (index: Int, element: Element) {
        let indexMin = vDSP.indexOfMinimum(elements)
        return (Int(indexMin.0), indexMin.1)
    }
    
    func abs() -> Self {
        return vDSP.absolute(self).asVector()
    }
}

@available(iOS 14, *)
public extension Vector {
    func diagonalMatrix() -> Matrix<Element> where Element: ExpressibleByFloatLiteral {
        let newElements = self.elements.enumerated().map { index, value -> [Element] in
            var line = [Element](repeating: 0.0, count: self.count)
            line[index] = value
            return line
        }.reduce([]) { $0 + $1 }
        
        return Matrix(elements: newElements, rows: self.count, columns: self.count)
    }
    
    func asMatrix() -> Matrix<Element> {
        return Matrix(elements: elements, rows: count, columns: 1)
    }
    
    mutating func dropFirst() {
        self = Self(elements: Array(elements.dropFirst()))
    }
}

@available(iOS 14, *)
extension Array where Element == Double {
    func asVector() -> Vector<Element> {
        return Vector(elements: self)
    }
}
