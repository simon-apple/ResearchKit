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
    
    public var testEnded: Bool = false
    public var initialSampleEnded: Bool = false
    
    public var xSample = Matrix<Double>(elements: [], rows: 0, columns: 2)
    public var ySample = Matrix<Double>(elements: [], rows: 0, columns: 1)
    
    public let allFrequencies: [Double]
    public var initialSamples = [Bool]()
    @objc public var previousAudiogram: [Double: Double] = [:] {
        didSet { didSetPreviousAudiogram() }
    }

    private let optmizer = ORKNewAudiometryMinimizer()
    private var theta = Vector<Double>(elements: [1, 1])
    private let kernelLenght: Double
    private let stoppingCriteria: Double
    private var stoppingCriteriaSave = [Double]()
    private let stoppingCriteriaCountMin = 35
    private let stoppingCriteriaCountMax = 75
    private var lastProgress: Float = 0.0
    
    fileprivate let channel: ORKAudioChannel
    fileprivate var stimulus: ORKAudiometryStimulus?
    fileprivate var results = [Double: Double]()
    fileprivate var preStimulusResponse: Bool = true

    // Settings
    fileprivate let initialLevel: Double
    fileprivate let minLevel: Double
    fileprivate let maxLevel: Double
    
    // Initial Sampling
    fileprivate var testFs: Vector<Double>
    fileprivate var revFs: Vector<Double>
    
    // Extra result data
    fileprivate var resultUnit = ORKdBHLToneAudiometryUnit()
    fileprivate var resultUnitsTable: [Double: [ORKdBHLToneAudiometryUnit]] = [:]
    @objc public var fitMatrix: [String: Double] = [:]

    @objc
    public convenience init(channel: ORKAudioChannel) {
        self.init(channel: channel,
                  initialLevel: 42.5,
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
                  kernelLenght: 3.0,
                  stoppingCriteria: 0.7)
    }
    
    public init(channel: ORKAudioChannel,
                initialLevel: Double,
                minLevel: Double,
                maxLevel: Double,
                frequencies: [Double],
                kernelLenght: Double,
                stoppingCriteria: Double) {
        self.initialLevel = initialLevel
        self.minLevel = minLevel
        self.maxLevel = maxLevel
        self.kernelLenght = kernelLenght
        self.stoppingCriteria = stoppingCriteria
        
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
        
        let reversals = [1000.0, allFrequencies.max() ?? 8000.0, allFrequencies.min() ?? 250.0]
        self.revFs = Self.bark(reversals.asVector()) // frequencies that need reversals
        
        super.init()
        createNewUnit()
    }
    
    public var progress: Float {
        let stoppingCriteriaSaveCount = Float(stoppingCriteriaSave.count)
        let fromMax = stoppingCriteriaSaveCount / Float(stoppingCriteriaCountMax)

        let fromMin = stoppingCriteriaSaveCount / Float(stoppingCriteriaCountMin)
        let lastStoppingCriteria = stoppingCriteriaSave.last ?? 1.0
        let fromValue = 1.0 - ((lastStoppingCriteria - stoppingCriteria) / (1.0 - stoppingCriteria))
        let fromStoppingCriteria = min(fromMin, Float(fromValue) * 0.85)

        let newProgress = max(fromStoppingCriteria, fromMax)
        let progress = max(lastProgress, newProgress)
        lastProgress = progress
        
        return progress
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
            // start from +5dB above the old audiogram
            dbHLPoint = min(dbHLPoint + (stepSize / 2), maxLevel)
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
        if let last = stoppingCriteriaSave.last {
            let sampleCount = stoppingCriteriaSave.count + initialSamples.count
            let hitStoppingCriteria = last <= stoppingCriteria
            let hitMinimumSampling = sampleCount >= stoppingCriteriaCountMin
            let hitMaximumSampling = sampleCount >= stoppingCriteriaCountMax

            if (hitStoppingCriteria && hitMinimumSampling) || hitMaximumSampling {
               return false
           }
        }
        
        let evaluated = newPoint(xSample, ySample, theta)
        stoppingCriteriaSave.append(evaluated.i)
        stimulus = ORKAudiometryStimulus(frequency: ORKNewAudiometry.hz(evaluated.nextPoint[0]),
                                         level: evaluated.nextPoint[1],
                                         channel: self.channel)

        return true
    }
    
    func finalSampling() {
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
    
    func newPointGrid(_ xSample: Matrix<Double>,
                      _ ySample: Matrix<Double>,
                      _ theta: Vector<Double>) -> Matrix<Double> {
        let c = 1.043_452_464_251_151_8
        let lowerX = bark(allFrequencies.min() ?? 250)
        let upperX = bark(allFrequencies.max() ?? 8000)
        let lowerY = minLevel
        let upperY = maxLevel
        
        let grids = Matrix.mGrid(xRange: lowerX...upperX,
                                 xSteps: 35, yRange: lowerY...upperY,
                                 ySteps: 80)
        let grid = Matrix.stack(grids.0, grids.1)
        let xNew = Matrix.reshape2columns(grid)
        let lenght = kernelLenght

        let muVar = ORKNewAudiometry.getMuVar(xNew, xSample, ySample.asVector(), theta, lenght)
        var save_dat = Matrix(repeating: 0.0, rows: 0, columns: 3)
        
        var idx = 0
        for i in 0..<grids.0.shape.rows {
            for j in 0..<grids.1.shape.columns {
                let muTmp = muVar.a_mu.elements[idx]
                let varTmp = muVar.a_var.elements[idx]
                
                let kappa = 1.0 / sqrt(1.0 + Double.pi * varTmp / 8.0)
                let sigmoid = ORKNewAudiometry.sigmoid([kappa * muTmp].asVector())
                let term1 = computeEntropy(sigmoid[0])
                let term2 = (c * exp((-(muTmp ** 2)) /
                            (2 * (varTmp + c ** 2)))) / sqrt(varTmp + c ** 2)
                
                let I = term1 - term2
                save_dat.appendRow([grids.0[i, j], grids.1[i, j], I])
                idx += 1
            }
        }
        
        return save_dat
    }
    
    func newPoint(_ xSample: Matrix<Double>,
                  _ ySample: Matrix<Double>,
                  _ theta: Vector<Double>) -> (nextPoint: Vector<Double>, i: Double) {
        
        let save_dat = newPointGrid(xSample, ySample, theta)
        let indexMax = save_dat.getColumn(2).asVector().indexOfMaximum()
        let newPoint = [save_dat[indexMax.index, 0], save_dat[indexMax.index, 1]].asVector()
        
        return (newPoint, indexMax.element)
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
