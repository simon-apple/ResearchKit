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
import Foundation

@objcMembers
public class Interpolators: NSObject {
    @inlinable
    public static func interp1d(xValues: [Double], yValues: [Double], xPoint: Double) -> Double {
        precondition(xValues.count >= 2)
        precondition(xValues.count == yValues.count)

        let xIndex = xValues.partitioningIndex { $0 >= xPoint }
        let index = min(xIndex, xValues.count - 1)
        if xValues[index] == xPoint || index == 0 {
            return yValues[index]
        }
        
        let xValue1 = xValues[index - 1]
        let xValue2 = xValues[index]
        let xDiff = xValue2 - xValue1
        
        let yValue1 = yValues[index - 1]
        let yValue2 = yValues[index]
        let yDiff = yValue2 - yValue1
        
        let diff = (xPoint - xValue1) * (yDiff / xDiff)
        return yValue1 + diff
    }
    
    @inlinable
    public static func interp(indices: [Double], xValues: [Double], yValues: [Double]) -> [Double] {
        precondition(indices.count >= 2)
        precondition(xValues.count == yValues.count)

        return indices.map { interp1d(xValues: xValues, yValues: yValues, xPoint: $0) }
    }
    
    @available(iOS 14, *)
    @inlinable
    public static func log2Interpolate(values: [Double], atIndices indices: [Double]) -> [Double] {
        return vDSP.linearInterpolate(values: values.map(log2), atIndices: indices).map(exp2)
    }
}

extension Array {
    // from swift-algorithms
    @inlinable
    public func partitioningIndex(where belongsInSecondPartition: (Element) throws -> Bool)
    rethrows -> Index {
        var currentCount = self.count
        var currentIndex = self.startIndex
        
        while currentCount > 0 {
            let half = currentCount / 2
            let mid = index(currentIndex, offsetBy: half)
            if try belongsInSecondPartition(self[mid]) {
                currentCount = half
            } else {
                currentIndex = index(after: mid)
                currentCount -= half + 1
            }
        }
        return currentIndex
    }
}
