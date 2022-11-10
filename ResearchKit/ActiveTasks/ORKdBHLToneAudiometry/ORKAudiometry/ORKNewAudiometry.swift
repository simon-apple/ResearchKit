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
// swiftlint:disable superfluous_disable_command identifier_name last_where
// swiftlint:disable superfluous_disable_command extension_access_modifier file_length

#if RK_APPLE_INTERNAL

import Accelerate
import Foundation

@available(iOS 14, *)
@objc public class ORKNewAudiometry: NSObject, ORKAudiometryProtocol {
    public var timestampProvider: ORKAudiometryTimestampProvider = { 0 }
    
    public var testEnded = false
    public var initialSampleEnded = false
    
    public var theta = Vector<Double>(elements: [1, 1])
    public var xSample = Matrix<Double>(elements: [], rows: 0, columns: 2)
    public var ySample = Matrix<Double>(elements: [], rows: 0, columns: 1)
    public var deleted = Matrix<Double>(elements: [], rows: 0, columns: 2)

    public let allFrequencies: [Double]
    public var initialSamples = [Bool]()
    @objc public var previousAudiogram: [Double: Double] = [:] {
        didSet { didSetPreviousAudiogram() }
    }

    private let optmizer = ORKNewAudiometryMinimizer()
    private let kernelLenght: Double
    private let maxSampleCount = 70
    private var coverage: Float = 0.0
    private var lastProgress: Float = 0.0
    
    fileprivate let channel: ORKAudioChannel
    fileprivate var stimulus: ORKAudiometryStimulus?
    fileprivate var results = [Double: Double]()
    fileprivate var preStimulusResponse = true

    // Settings
    fileprivate let initialLevel: Double
    fileprivate let minLevel: Double
    fileprivate let maxLevel: Double
    
    // Initial Sampling
    fileprivate let testFsCount: Int
    fileprivate var testFs: Vector<Double>
    fileprivate var revFs: Vector<Double>
    
    // Extra result data
    fileprivate var resultUnit = ORKdBHLToneAudiometryUnit()
    fileprivate var resultUnitsTable: [Double: [ORKdBHLToneAudiometryUnit]] = [:]
    @objc public var fitMatrix: [String: Double] = [:]

    @objc
    public convenience init(channel: ORKAudioChannel) {
        self.init(channel: channel,
                  initialLevel: 45,
                  minLevel: -10,
                  maxLevel: 75,
                  frequencies: [1000, 2000, 4000, 8000, 500, 250])
    }
    
    @objc
    public convenience init(channel: ORKAudioChannel,
                            initialLevel: Double,
                            minLevel: Double,
                            maxLevel: Double,
                            frequencies: [Double]) {
        self.init(channel: channel,
                  initialLevel: initialLevel,
                  minLevel: minLevel,
                  maxLevel: maxLevel,
                  frequencies: frequencies,
                  kernelLenght: 3.0)
    }
    
    public init(channel: ORKAudioChannel,
                initialLevel: Double,
                minLevel: Double,
                maxLevel: Double,
                frequencies: [Double],
                kernelLenght: Double) {
        self.initialLevel = initialLevel
        self.minLevel = minLevel
        self.maxLevel = maxLevel
        self.kernelLenght = kernelLenght
        
        // Remove duplicates without changing order
        self.allFrequencies = frequencies.reduce(into: [Double]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }

        self.channel = channel
        self.stimulus = ORKAudiometryStimulus(frequency: allFrequencies[0],
                                              level: initialLevel,
                                              channel: channel)

        // Initial Sampling params
        self.testFs = Self.bark(allFrequencies.asVector())
        self.testFsCount = self.testFs.count

        let reversals = [1000.0, allFrequencies.max() ?? 8000.0, allFrequencies.min() ?? 250.0]
        self.revFs = Self.bark(reversals.asVector()) // frequencies that need reversals
        
        super.init()
        createNewUnit()
    }
    
    public var progress: Float {
        let ratio: Float = 1 / 5
        
        let fromInitialSampling = 1.0 - (Float(testFs.count) / Float(testFsCount))
        let fromSamples = (fromInitialSampling * ratio) + (coverage * (1.0 - ratio))
        let fromMax = Float(ySample.count) / Float(maxSampleCount)
        
        let newProgress = max(fromMax, fromSamples)
        lastProgress = max(lastProgress, newProgress)
        return lastProgress
    }
        
    public func nextStimulus() -> ORKAudiometryStimulus? {
        return stimulus
    }
    
    public func registerPreStimulusDelay(_ preStimulusDelay: Double) {
        resultUnit.preStimulusDelay = preStimulusDelay
    }
    
    public func registerStimulusPlayback() {
          preStimulusResponse = false
     }
    
    public func registerResponse(_ response: Bool) {
        guard let lastStimulus = stimulus, !preStimulusResponse else { return }
        
        let freqPoint = bark(lastStimulus.frequency)
        
        if lastStimulus.level == maxLevel && response == false {
            // handle levels higher than maxLevel
            xSample.appendRow([freqPoint, maxLevel + 1])
            ySample.appendRow([1])
        } else if lastStimulus.level == minLevel && response == true {
            // handle levels lower than minLevel
            xSample.appendRow([freqPoint, minLevel - 1])
            ySample.appendRow([0])
        } else {
            let dbHLPoint = lastStimulus.level
            xSample.appendRow([freqPoint, dbHLPoint])
            ySample.appendRow([response ? 1 : 0])
        }
        
        let lastResponse = ySample.elements.last == 1
        updateUnit(with: lastResponse)
        preStimulusResponse = true
        
        if !nextInitialSample() {
            // Check if initial sampling is invalid
            if (!initialSamples.isEmpty &&
                (initialSamples.allSatisfy { $0 } || initialSamples.allSatisfy { !$0 })) {
                testEnded = true
                return
            }
        
            initialSampleEnded = true
            stimulus = nil
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.theta = self.fit()
                let shouldEndTest = !self.nextSample()
                
                if shouldEndTest {
                    self.lastProgress = 1.0
                    self.finalSampling()
                    self.testEnded = true
                } else {
                    self.createNewUnit()
                }
            }
        } else {
            // Store initial sample separetedly so it can be checked later
            initialSamples.append(response)
            createNewUnit()
        }
    }
    
    public func signalClipped() {
        registerResponse(false)
    }
    
    public func resultSamples() -> [ORKdBHLToneAudiometryFrequencySample] {
        return results.map { key, value in
            let sample = ORKdBHLToneAudiometryFrequencySample()
            sample.frequency = key
            sample.calculatedThreshold = value
            sample.channel = channel
            return sample
        }.sorted { $0.frequency < $1.frequency }
    }
    
    @objc
    public func deletedSamples() -> [ORKdBHLToneAudiometryFrequencySample] {
        return deleted.rows.map { deletedSample in
            let deletedSampleArray = Array(deletedSample)
            let sample = ORKdBHLToneAudiometryFrequencySample()
            sample.frequency = hz(deletedSampleArray[0])
            sample.calculatedThreshold = deletedSampleArray[1]
            sample.channel = channel
            return sample
        }
    }
}

@available(iOS 14, *)
public extension ORKNewAudiometry {
    func createNewUnit() {
        guard let lastStimulus = stimulus else { return }

        resultUnit = ORKdBHLToneAudiometryUnit()
        resultUnit.dBHLValue = lastStimulus.level
        resultUnit.startOfUnitTimeStamp = timestampProvider()
        
        var units = resultUnitsTable[lastStimulus.frequency] ?? []
        units.append(resultUnit)
        resultUnitsTable[lastStimulus.frequency] = units
    }
    
    func updateUnit(with response: Bool) {
        if response {
            resultUnit.userTapTimeStamp = timestampProvider()
        } else {
            resultUnit.timeoutTimeStamp = timestampProvider()
        }
    }
    
    @objc func resultUnits() -> [ORKdBHLToneAudiometryFrequencySample] {
        return resultUnitsTable.map { freq, units -> ORKdBHLToneAudiometryFrequencySample in
            let sample = ORKdBHLToneAudiometryFrequencySample()
            sample.frequency = freq
            sample.calculatedThreshold = 0.0
            sample.channel = channel
            sample.units = units
            return sample
        }.sorted { $0.frequency < $1.frequency }
    }
}

@available(iOS 14, *)
extension ORKNewAudiometry {
    func didSetPreviousAudiogram() {
        if !previousAudiogram.isEmpty, Set(previousAudiogram.keys).isSuperset(of: allFrequencies) {
            _ = nextInitialSampleFromAudiogram()
            resultUnitsTable.removeAll()
            createNewUnit()
        }
    }
    
    func nextInitialSampleFromAudiogram() -> Bool {
        guard !testFs.isEmpty && !initialSampleEnded else {
            return false
        }
        
        guard let freqPoint = testFs.first else {
            // No more frequencies left, finish the initial sampling
            return false
        }
        
        let stepSize = 10.0
        let previousLevel = previousAudiogram.map { (bark($0.key), $0.value) }
            .filter { abs($0.0 - freqPoint) < 0.01 } // Check if it's equal ignoring fp errors
            .map { $0.1 }
        var dbHLPoint = previousLevel.first ?? initialLevel
        
        let responsesForFreq = zip(xSample.getColumn(0).elements, ySample.elements)
            .filter { abs($0.0 - freqPoint) < 0.01 } // Check if it's equal ignoring fp errors
            .map { $0.1 }
        
        if responsesForFreq.contains(0) && responsesForFreq.contains(1) {
            // Got reversal, proceed to next frequency
            testFs.dropFirst()
            return nextInitialSampleFromAudiogram()
        }
        
        if responsesForFreq.isEmpty {
            // start from +10dB above the old audiogram
            dbHLPoint = min(dbHLPoint + stepSize, maxLevel)
        } else if responsesForFreq.last == 1 {
            dbHLPoint = max(xSample[xSample.shape.rows - 1, 1] - stepSize, minLevel)
        } else if responsesForFreq.last == 0 {
            dbHLPoint = min(xSample[xSample.shape.rows - 1, 1] + stepSize, maxLevel)
        }
        
        stimulus = ORKAudiometryStimulus(frequency: hz(freqPoint),
                                         level: dbHLPoint,
                                         channel: channel)
        return true
    }

    func nextInitialSample(skipReversalFrequencies: Bool = false) -> Bool {
        if !previousAudiogram.isEmpty {
            return nextInitialSampleFromAudiogram()
        }
        
        guard !testFs.isEmpty && !initialSampleEnded else {
            return false
        }

        let freqPoint = testFs[0]
        var dbHLPoint = stimulus?.level ?? initialLevel
        
        let jumpF = bark(500)
        let xSampleFreqs = xSample.getColumn(0).elements
        
        let ySample1k = zip(xSampleFreqs, ySample.elements)
            .filter { $0.0 == bark(1000) }
            .last?.1 ?? 0
        
        let dbHLPoint1k = zip(xSampleFreqs, xSample.getColumn(1).elements)
            .filter { $0.0 == bark(1000) }
            .last?.1 ?? initialLevel
        
        if revFs.contains(freqPoint) && !skipReversalFrequencies { // need reversal
            let responsesForFreq = zip(xSampleFreqs, ySample.elements)
                .filter { abs($0.0 - freqPoint) < 0.01 } // Check if it's equal ignoring fp errors
                .map { $0.1 }
            
            if (responsesForFreq.last == 1 && dbHLPoint == minLevel) ||
                (responsesForFreq.last == 0 && dbHLPoint == maxLevel) {
                testFs.dropFirst()
                return nextInitialSample()
            }
            
            let negResp = responsesForFreq.contains(0)
            let posResp = responsesForFreq.contains(1)

            if negResp == false || posResp == false { // keep on same frequency
                if (freqPoint == jumpF) && (xSample[xSample.shape.rows - 1, 0] != freqPoint) {
                    // use 1k data as reference
                    if ySample1k == 0 { // last 1k response is negative
                        dbHLPoint = min(dbHLPoint1k + 10, maxLevel)
                    } else { // last 1k response is positive
                        dbHLPoint = max(dbHLPoint1k - 10, -minLevel)
                    }
                } else {
                    if ySample.elements.last == 0 { // last response is negative
                        dbHLPoint = min(dbHLPoint + 10, maxLevel)
                    } else { // last response is positive
                        dbHLPoint = max(dbHLPoint - 10, minLevel)
                    }
                }
                
                stimulus = ORKAudiometryStimulus(frequency: hz(testFs[0]),
                                                 level: dbHLPoint,
                                                 channel: channel)

            } else { // jump to next frequency
                testFs.dropFirst()
                return nextInitialSample(skipReversalFrequencies: true)
            }
        } else { // only one response needed
            if freqPoint == jumpF { // use 1k data as reference
                if ySample1k == 0 { // last 1k response is negative
                    dbHLPoint = min(dbHLPoint1k + 10, maxLevel)
                } else { // last 1k response is positive
                    dbHLPoint = max(dbHLPoint1k - 10, minLevel)
                }
            } else {
                if ySample.elements.last == 0 { // last response is negative
                    dbHLPoint = min(dbHLPoint + 10, maxLevel)
                } else { // last response is positive
                    dbHLPoint = max(dbHLPoint - 10, minLevel)
                }
            }
            
            stimulus = ORKAudiometryStimulus(frequency: hz(testFs[0]),
                                             level: dbHLPoint,
                                             channel: channel)
            testFs.dropFirst()
        }
        
        return true
    }
    
    func nextSample() -> Bool {
        // get coverage matrix
        let coverageMatrix = checkCoverage()
        let covered = coverageMatrix.filterOnColumn(4) { $0 == 1 }
        coverage = Float(covered.shape.rows) / Float(coverageMatrix.shape.rows)
        
        // check stopping criteria
        let hitStoppingCriteria = coverage >= 1.0
        let hitMaximumSampling = ySample.count >= maxSampleCount
        if hitStoppingCriteria || hitMaximumSampling {
            return false
        }
        
        // check and remove outliers after 5 sampled points
        let sampledPoints = ySample.shape.rows - initialSamples.count
        if sampledPoints >= 5 {
            let outliersResult = removeOutlierFit(coverageMatrix, deleted)
            deleted.appendRows(of: outliersResult.deleted)
            ySample = outliersResult.ySample
            xSample = outliersResult.xSample
        }
        
        // get next point
        let evaluated = newPoint(coverageMatrix)
        stimulus = ORKAudiometryStimulus(frequency: ORKNewAudiometry.hz(evaluated[0]),
                                         level: evaluated[1],
                                         channel: self.channel)

        return true
    }
    
    public func finalSamplingFit() -> Matrix<Double> {
        let lowerY = xSample.getColumn(1).minimum() - 5
        let upperY = xSample.getColumn(1).maximum() + 5
        
        let minFreq = allFrequencies.min() ?? 250
        let maxFreq = allFrequencies.max() ?? 8000
        let lowerX = bark(minFreq)
        let upperX = bark(maxFreq)
        
        let grids = Matrix.mGrid(xRange: lowerX...upperX,
                                 xSteps: 85,
                                 yRange: lowerY...upperY,
                                 ySteps: 100)
        let gridX1 = grids.0
        let gridX2 = grids.1
        let grid = Matrix.stack(gridX1, gridX2)
        let xNew = Matrix.reshape2columns(grid)
        
        let probPredict = ORKNewAudiometry
            .getProbMatrix(xNew, xSample, ySample.asVector(), theta, kernelLenght)
            .reshaped(rows: gridX1.shape.rows, columns: gridX1.shape.columns)
        
        let fit = getFit(gridX1, gridX2, probPredict)
        return fit
    }
    
    func finalSampling() {
        let fit = finalSamplingFit()
        let fitFreqs = fit.getColumn(0).elements
        let fitLevels = fit.getColumn(1).elements

        for freq in allFrequencies {
            results[freq] = Interpolators.interp1d(xValues: fitFreqs,
                                                   yValues: fitLevels,
                                                   xPoint: bark(freq))
        }
        
        fitMatrix = zip(fitFreqs, fitLevels).reduce(into: [:]) {
            $0[String($1.0)] = $1.1
        }
    }
}

@available(iOS 14, *)
public extension ORKNewAudiometry {
    func newPointGrid(_ coverageMatrix: Matrix<Double>) -> Matrix<Double> {
        let c = 1.043_452_464_251_151_8
        
        // Get range where not covered
        let notCovered = coverageMatrix.filterOnColumn(4) { $0 == 0 }
        
        // Create n X 2 matrix where first column is the points not covered and
        // second column is the dB range (2.5 dB increments)
        var xNew = Matrix<Double>(elements: [], rows: 0, columns: 2)
        
        for rowSlice in notCovered.rows {
            let row = Array(rowSlice)
            let dBRange = vDSP.linearInterpolate(values: [minLevel, maxLevel], atIndices: [0, 34])
            for dB in dBRange {
                xNew.appendRow([row[0], dB])
            }
        }
        
        // Get GP statistics for matrix
        let muVar = Self.getMuVar(xNew, xSample, ySample.asVector(), theta, kernelLenght)
        
        // Loop over matrix and compute BALD statistics
        var baldMatrix = Matrix<Double>(elements: [], rows: 0, columns: 3)
        
        for idx in 0..<xNew.shape.rows {
            let muTmp = muVar.a_mu.elements[idx]
            let varTmp = muVar.a_var.elements[idx]
            
            let kappa = 1.0 / sqrt(1.0 + Double.pi * varTmp / 8.0)
            let sigmoid = ORKNewAudiometry.sigmoid([kappa * muTmp].asVector())
            let term1 = computeEntropy(sigmoid[0])
            let term2 = (c * exp((-(muTmp ** 2)) /
                        (2 * (varTmp + c ** 2)))) / sqrt(varTmp + c ** 2)
            
            let I = term1 - term2
            baldMatrix.appendRow([xNew[idx, 0], xNew[idx, 1], I])
        }
        
        return baldMatrix
    }
    
    func newPoint(_ coverageMatrix: Matrix<Double>) -> Vector<Double> {
        
        // Get top BALD point
        let baldMatrix = newPointGrid(coverageMatrix)
        let indexMax = baldMatrix.getColumn(2).asVector().indexOfMaximum()
        var newPoint = [baldMatrix[indexMax.index, 0], baldMatrix[indexMax.index, 1]].asVector()
        
        // Get number heard and not heard for this point
        let notCovered = coverageMatrix.filterOnColumn(4) { $0 == 0 }
        let numHeard = notCovered.filterOnColumn(0) { $0 == newPoint[0] }[0, 1]
        let numUnheard = notCovered.filterOnColumn(0) { $0 == newPoint[0] }[0, 2]
        
        // nudge dB direction if number of points >= 3 based on number of heard and unheard
        if numHeard + numUnheard >= 3 {
            let diff = abs(numHeard - numUnheard)
            if numHeard > numUnheard {
                newPoint[1] = newPoint[1] - 1.5 * diff
            } else if numHeard < numUnheard {
                newPoint[1] = newPoint[1] + 1.5 * diff
            }
        }

        // clip point to dB range
        newPoint[1] = max(minLevel, min(newPoint[1], maxLevel))

        return newPoint
    }
    
    func checkCoverage(xWidth: Double = 1.75,
                       yWidth: Double = 10,
                       numHeardNeeded: Int = 2,
                       numUnheardNeeded: Int = 2) -> Matrix<Double> {
        
        // store results in matrix: point, numHeard, numNotHeard, yEst, covered
        var coverageMatrix = Matrix<Double>(elements: [], rows: 0, columns: 5)
        
        let freqRange = bark(allFrequencies.asVector())
        let barkRange = vDSP.linearInterpolate(values: [freqRange.minimum(), freqRange.maximum()],
                                               atIndices: [0, 34])

        // loop frequency range
        for xPoint in barkRange {
            // get estimated dB fit for point to use to build box
            var xNew = Matrix<Double>(elements: [], rows: 0, columns: 2)
            
            let dBRange = vDSP.linearInterpolate(values: [minLevel, maxLevel], atIndices: [0, 44])
            for dB in dBRange {
                xNew.appendRow([xPoint, dB])
            }
            
            let ySampleVector = ySample.asVector()
            let probMatrix = Self.getProbMatrix(xNew, xSample, ySampleVector, theta, kernelLenght)
                .reshaped(rows: 1, columns: -1)
                        
            let yEst: Double
            if probMatrix.maximum() < 0.5 {
                yEst = maxLevel
            } else if probMatrix.minimum() > 0.5 {
                yEst = minLevel
            } else {
                let idx = probMatrix.elements.firstIndex(where: { $0 > 0.5 }) ?? 1
                let x2 = probMatrix[0, idx]
                let x1 = probMatrix[0, idx - 1]
                let y2 = dBRange[idx]
                let y1 = dBRange[idx - 1]
                yEst = y1 + ((0.5 - x1) / (x2 - x1)) * (y2 - y1)
            }
            
            // current window bounds to look at
            let xMin = xPoint - xWidth
            let xMax = xPoint + xWidth
            let yMin = yEst - yWidth
            let yMax = yEst + yWidth
            
            // get points in  window
            let xSample0 = xSample.getColumn(0).elements
            let indices0 = xSample0.indices.filter { xSample0[$0] >= xMin && xSample0[$0] <= xMax }
            let xSample1 = xSample.getColumn(1).elements
            let indices1 = xSample1.indices.filter { xSample1[$0] >= yMin && xSample1[$0] <= yMax }
            let indices = indices0.filter { indices1.contains($0) }
                        
            // get the heard and unheard points
            let yTemp = ySample.getRows(indices)
            let numHeard = yTemp.elements.filter { $0 == 1 }.count
            let numUnheard = yTemp.elements.filter { $0 == 0 }.count
            
            // check if requirements met met
            let covered = numHeard >= numHeardNeeded && numUnheard >= numUnheardNeeded ? 1.0 : 0.0

            // store results
            coverageMatrix.appendRow([xPoint, Double(numHeard), Double(numUnheard), yEst, covered])
        }
        
        return coverageMatrix
    }
    
    func removeOutlierFit(_ coverageMatrix: Matrix<Double>,
                          _ deleted: Matrix<Double>,
                          yDiff: Double = 0.2) -> (xSample: Matrix<Double>,
                                                   ySample: Matrix<Double>,
                                                   deleted: Matrix<Double>) {
        // keep track of deleted points
        var idxToDelete = [Int]()
        
        let freqs = coverageMatrix.getColumn(0).elements
        let responses = coverageMatrix.getColumn(3).elements
        
        // loop over points
        xSampleLoop: for idx in 0..<xSample.shape.rows {
            // get current point
            let x = xSample.getRow(idx)
            let resp = ySample[idx, 0]
            
            // if already deleted somewhere very close to this point do not deleted again
            for dIdx in 0..<deleted.shape.rows {
                let d = deleted.getRow(dIdx)
                if Matrix.allClose(x, d, atol: 1) {
                    continue xSampleLoop
                }
            }
            
            // get estimated curve at point by linear interpolation
            let yEst = Interpolators.interp1d(xValues: freqs, yValues: responses, xPoint: x[0, 0])
            
            // remove if difference greater than y_diff and on wrong side of curve delete
            if resp == 1 {
                if x[0, 1] < yEst && abs(x[0, 1] - yEst) > yDiff {
                    idxToDelete.append(idx)
                }
            } else {
                if x[0, 1] > yEst && abs(x[0, 1] - yEst) > yDiff {
                    idxToDelete.append(idx)
                }
            }
            
        }
        
        // delete point(s) from sample and record
        let toDelete = xSample.gatherRows(idxToDelete)
        let newXSample = xSample.filterRows(idxToDelete)
        let newYSample = ySample.filterRows(idxToDelete)
        
        return (newXSample, newYSample, toDelete)
    }
}

@available(iOS 14, *)
extension ORKNewAudiometry {
    func fit() -> Vector<Double> {
        let lenght = kernelLenght
        let minimizedTheta = optmizer.minimize(theta[0], theta[1]) { [xSample, ySample] in
            return Self.nllFn([$0, $1].asVector(), xSample, ySample, lenght)
        }
        
        return minimizedTheta
            .map { $0.doubleValue }
            .asVector()
    }
    
    func getFit(_ grid_x1: Matrix<Double>,
                _ grid_x2: Matrix<Double>,
                _ prob_matrix: Matrix<Double>) -> Matrix<Double> {
        var best_fit = Matrix<Double>(elements: [], rows: 0, columns: 2)
        
        for i in 0..<grid_x1.shape.rows {
            let x_point = grid_x1[i, 0]
            let y_point = Interpolators.interp1d(xValues: prob_matrix.getRow(i).elements,
                                                 yValues: grid_x2.getRow(i).elements,
                                                 xPoint: 0.5)
            best_fit.appendRow([x_point, y_point])
        }
        
        return best_fit
    }
    
    func findNearest(_ vector: Vector<Double>, _ value: Double) -> Int {
        let idx = (vector - value).abs().indexOfMinimum()
        return idx.index
    }
    
    func computeEntropy(_ p: Double) -> Double {
        var p = p
        p = p < 0.000_01 ? 0.000_01 : p
        p = p > 0.999_99 ? 0.999_99 : p
        
        let entropy = -p * log2(p) - (1 - p) * log2(1 - p)
        return entropy
    }
}

@available(iOS 14, *)
extension ORKNewAudiometry {
    public static func nllFn(_ theta: Vector<Double>,
                             _ x: Matrix<Double>,
                             _ t: Matrix<Double>,
                             _ kernelLenght: Double) -> Double {
        let t = t.reshaped(rows: -1, columns: 1)
        let k_a = k(x, theta, length: kernelLenght)
        let k_a_inv = k_a.inv()
        let a_h = posteriorMode(x, t, k_a).reshaped(rows: -1, columns: 1)
        let w = w(a_h.asVector())
        
        let ll1 = -0.5 * a_h.transposed() * k_a_inv * a_h
        let ll2 = ll1 - 0.5 * k_a.slogdet().determinant
        let ll3 = ll2 - 0.5 * (w + k_a_inv).slogdet().determinant
        
        let exp = Matrix.exp(a_h - (a_h.elements.max() ?? 0.0))
        let log = Matrix.log(1.0 + exp)
        let ll = ll3[0, 0] + (t.asVector() * a_h.asVector()) - log.sum()

        return -ll
    }
    
    static func posteriorMode(_ x: Matrix<Double>,
                              _ t: Matrix<Double>,
                              _ k_a: Matrix<Double>,
                              _ maxIter: Int = 15,
                              _ tol: Double = 1e-9) -> Matrix<Double> {
        var a_h = Vector(repeating: 0.0, count: t.shape.rows)
        let eye = Matrix.eye(x.shape.rows)

        for _ in 0..<maxIter {
            let w = w(a_h)
            let q = eye + w * k_a
            let qInv = q.inv()
            let sigmoid = sigmoid(a_h).asMatrix()
            let wA_h = w * a_h.asMatrix()
            let a_h_new = (k_a * qInv) * (t - sigmoid + wA_h)
            let a_h_diff = vDSP.absolute(a_h_new - a_h.asMatrix()).asVector()
            a_h = a_h_new.asVector()
            
            if !(a_h_diff.maximum() > tol) {
                break
            }
        }

        return a_h.asMatrix()
    }
    
    static func getMuVar(_ x_test: Matrix<Double>,
                         _ x: Matrix<Double>,
                         _ t: Vector<Double>,
                         _ theta: Vector<Double>,
                         _ kernelLenght: Double) -> (a_mu: Matrix<Double>, a_var: Matrix<Double>) {
        let k_a = k(x, theta, length: kernelLenght)
        let k_s = kernel(x, x_test, theta: theta, length: kernelLenght)
        let a_h = posteriorMode(x, t.asMatrix(), k_a)

        let w_inv = w(a_h.asVector()).inv()
        let r_inv = (w_inv + k_a).inv()

        let a_test_mu = k_s.transposed() * (t - sigmoid(a_h.asVector())).asMatrix()
        let sum = ((r_inv * k_s) .* k_s).sum(along: .columns)
        let a_test_var = k(x_test, theta, length: kernelLenght, diagOnly: true) - sum.asMatrix()

        return (a_test_mu, a_test_var)
    }
    
    static func getProbMatrix(_ x_test: Matrix<Double>,
                              _ x: Matrix<Double>,
                              _ t: Vector<Double>,
                              _ theta: Vector<Double>,
                              _ kernelLenght: Double) -> Matrix<Double> {
        let muVar = getMuVar(x_test, x, t, theta, kernelLenght)
        let a = (1.0 + Double.pi * muVar.a_var / 8)
        let kappa = vDSP.divide(1.0, vForce.sqrt(a))
        
        return sigmoid(vDSP.multiply(kappa, muVar.a_mu.elements).asVector()).asMatrix()
    }

    static func kernel(_ x1: Matrix<Double>,
                       _ x2: Matrix<Double>,
                       theta: Vector<Double>,
                       length: Double) -> Matrix<Double> {
        // Squared exponential kernel (also known as radial basis)
        let op1 = x1.getColumn(0).pow(expoent: 2).reshaped(rows: -1, columns: 1)
        let op2 = x2.getColumn(0).pow(expoent: 2).asVector()
        let op3 = x1.getColumn(0).reshaped(rows: -1, columns: 1) *
                  x2.getColumn(0).reshaped(rows: -1, columns: 1).transposed()
        
        let sqdist = (op1 + op2) - (2 * op3)
        let k_RBF = pow(theta[0], 2) * Matrix.exp(-0.5 / length ** 2 * sqdist)
        
        // Linear kernel
        let k_Linear = theta[1] ** 2 + (x1.getColumn(1).reshaped(rows: -1, columns: 1) *
                                        x2.getColumn(1).reshaped(rows: -1, columns: 1).transposed())
        
        return k_RBF + k_Linear
    }
    
    static func k(_ x: Matrix<Double>,
                  _ theta: Vector<Double>,
                  length: Double,
                  diagOnly: Bool = false,
                  nu: Double = 5) -> Matrix<Double> {
        guard diagOnly else {
            let eye = Matrix.eye(x.shape.rows)
            let kernel = kernel(x, x, theta: theta, length: length)
            return kernel + (nu * eye)
        }
    
        let tmp = theta[0] ** 2 + nu
        
        let column = x.getColumn(1)
        let tmp1 = theta[1] ** 2 + column.reshaped(rows: -1, columns: 1).multipliedByTransposed()
        let tmp1Diag = tmp1.diagonalVector()
        
        return Matrix(tmp + tmp1Diag).reshaped(rows: -1, columns: 1)
    }

    static func sigmoid(_ x: Vector<Double>) -> Vector<Double> {
        let exp = vForce.exp(vDSP.negative(x))
        return vDSP.divide(1, vDSP.add(1, exp)).asVector()
    }
    
    static func w(_ a: Vector<Double>) -> Matrix<Double> {
        let sigmoidA = sigmoid(a)
        let r = vDSP.multiply(sigmoidA, vDSP.add(1, vDSP.negative(sigmoidA)))
        let mapR = r.map { $0 < 1e-5 ? 1e-5 : $0 }.asVector()
        return mapR.diagonalMatrix()
    }
}

@available(iOS 14, *)
extension ORKNewAudiometry {
    func bark(_ x: Double) -> Double {
        return Self.bark(x)
    }

    static func bark(_ x: Double) -> Double {
        return bark([x])[0]
    }
    
    func bark(_ x: Vector<Double>) -> Vector<Double> {
        return Self.bark(x)
    }
    
    static func bark(_ x: Vector<Double>) -> Vector<Double> {
        let divided = vDSP.divide(x, 600.0)
        let asinh = vForce.asinh(divided)
        return vDSP.multiply(6, asinh).asVector()
    }
    
    func hz(_ x: Double) -> Double {
        return Self.hz(x)
    }
    
    static func hz(_ x: Double) -> Double {
        return hz([x])[0]
    }
    
    func hz(_ x: Vector<Double>) -> Vector<Double> {
        return Self.hz(x)
    }
    
    static func hz(_ x: Vector<Double>) -> Vector<Double> {
        let divided = vDSP.divide(x, 6.0)
        let asinh = vForce.sinh(divided)
        return vDSP.multiply(600.0, asinh).asVector()
    }
}

#endif
