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

import Accelerate
import Foundation

public struct ORKNewAudiometryState {
    public let currentTone: ORKAudiometryStimulus?
    public let responses: [(tone: ORKAudiometryStimulus, response: Bool)]
    public let deletedTones: [ORKdBHLToneAudiometryDeletedSample]
    public let uncoveredInitialSamplingFrequencies: [Double]
    public let previousAudiogram: [Double: Double]?
    
    // CV/Proto App only
    public let resultUnitsTable: [Double: [ORKdBHLToneAudiometryUnit]]
    public let resultUnit: ORKdBHLToneAudiometryUnit
}

@available(iOS 14, *)
@objc public class ORKNewAudiometry: NSObject, ORKAudiometryProtocol {
    public var timestampProvider: ORKAudiometryTimestampProvider = { 0 }
    
    @objc public var initialSampleEnded: Bool = false
    public var testEnded: Bool = false {
        didSet { statusDidChange() }
    }
    
    @objc public var previousAudiogram: [Double: Double] = [:] {
        didSet { didSetPreviousAudiogram() }
    }

    public var state: ORKNewAudiometryState {
        get { getCurrentState() }
        set { setState(newValue) }
    }
    
    public let allFrequencies: [Double]
    public var theta = Vector<Double>(elements: [30, 30])
    public var xSample = Matrix<Double>(elements: [], rows: 0, columns: 2)
    public var ySample = Matrix<Double>(elements: [], rows: 0, columns: 1)
    public var deleted = Matrix<Double>(elements: [], rows: 0, columns: 5) // freq, level, originalIndex, response, deletionTimestamp

    public var initialSamples = [Bool]()
    private let kernelLenght: Double
    private let maxSampleCount = UserDefaults.standard.integer(forKey: "maxSampleCount")
    private var lastProgress: Float = 0.0
    
    fileprivate let channel: ORKAudioChannel
    fileprivate var results = [Double: Double]()
    fileprivate var preStimulusResponse = true
    
    fileprivate var statusProvider: ORKAudiometryStatusBlock?
    fileprivate var stimulus: ORKAudiometryStimulus? {
        didSet { statusDidChange() }
    }

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
    
    // State management
    private var stateHistory = [ORKNewAudiometryState]()
    private let stateLock = NSLock()

    // Background work queue
    private let workQueue = DispatchQueue(label: "ORKNewAudiometryQueue", qos: .userInitiated)
    private var workItem = DispatchWorkItem(block: {})
    
    @objc
    public convenience init(channel: ORKAudioChannel) {
        self.init(channel: channel,
                  initialLevel: 60,
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
                  kernelLenght: 4.0)
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
    }
    
    public var progress: Float {
        guard !testEnded else {
            return 1.0
        }
        return lastProgress
    }
        
    private func updateProgress(with coverage: Matrix<Double>? = nil) {
        let count = xSample.shape.rows
        var progressReport: Float = 0.0

        // if sample count < 20 then use iteration progress else window coverage progress
        if let coverageMatrix = coverage, count >= 20 {
            let progressWindow = Float(coverageMatrix.getColumn(4).mean())
            progressReport = progressWindow * 0.95
        } else {
            let progressIter = Float(count) / 60.0
            progressReport = progressIter
        }

        // always increase progress
        if progressReport <= lastProgress {
            progressReport = lastProgress + 0.015
        }
        
        // stop at 98% if not finished
        progressReport = min(progressReport, 0.98)
        
        // set previous progress to current
        lastProgress = progressReport
    }
        
    public func nextStatus(_ block: @escaping ORKAudiometryStatusBlock) {
        statusProvider = nil

        if testEnded {
            block(true, nil)
        } else if let currentStimulus = stimulus {
            block(false, currentStimulus)
        } else {
            statusProvider = block
        }
    }
    
    private func statusDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let provider = self?.statusProvider else { return }
            self?.nextStatus(provider)
        }
    }
    
    /// Returns the address of an onbject in memory converted to a String with the Integer representation
    private func getResultUnitAddress() -> String {
        // Get the memory address of the instance
        let address = Unmanaged.passUnretained(resultUnit).toOpaque()
        // Convert the address to an integer for printing
        let addressAsInt = Int(bitPattern: address)
        
        return String(addressAsInt, radix: 16)
    }
    
    public func registerPreStimulusDelay(_ pSDelay: Double) {
        createNewUnit()
        resultUnit.preStimulusDelay = pSDelay
    }
    
    public func registerUnitError(_ error: Error) {
        let errorCode = (error as NSError).code
        resultUnit.errorCode = errorCode
        resultUnit.errorDescription = error.localizedDescription
    }
    
    public func registerStimulusPlayback() {
          preStimulusResponse = false
     }
    
    public func registerResponse(_ response: Bool) {
        guard let lastStimulus = stimulus, !preStimulusResponse else { return }
        
        stateHistory.append(getCurrentState())
        let freqPoint = bark(lastStimulus.frequency)

        if !initialSampleEnded {
            // Store initial sample separetedly so it can be checked later
            initialSamples.append(response)
        }
        
        if initialSamples.count == 1, response == false {
            // rdar://108799286 ([Yodel-T1072] Repeat if participant misses the very first tone in MOL)
            preStimulusResponse = true
            stimulus = ORKAudiometryStimulus(frequency: lastStimulus.frequency, level: lastStimulus.level, channel: channel)
            return
        }
        
        stateLock.lock()
        if lastStimulus.level == maxLevel && response == false {
            // handle levels higher than maxLevel
            xSample.appendRow([freqPoint, maxLevel + 1])
            ySample.appendRow([1])
        } else if lastStimulus.level == minLevel && response == true {
            // handle levels lower than minLevel
            xSample.appendRow([freqPoint, minLevel - 1])
            ySample.appendRow([0])
        }
        
        xSample.appendRow([freqPoint, lastStimulus.level])
        ySample.appendRow([response ? 1 : 0])
        stateLock.unlock()

        let lastResponse = ySample.elements.last == 1
        updateUnit(with: lastResponse)
        preStimulusResponse = true
        
        if !nextInitialSample() {
            // Check if initial sampling is invalid
            if !initialSamples.isEmpty {
                if initialSamples.allSatisfy({ $0 }) {
                    results = Dictionary(uniqueKeysWithValues: allFrequencies.map { ($0, minLevel) })
                    testEnded = true
                    return
                } else if initialSamples.allSatisfy({ !$0 }) {
                    results = Dictionary(uniqueKeysWithValues: allFrequencies.map { ($0, maxLevel) })
                    testEnded = true
                    return
                }
            }
        
            stimulus = nil
            workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.stateLock.lock()
                
                let coverageMatrix = self.checkCoverage()
                self.updateProgress(with: coverageMatrix)
                let shouldEndTest = !self.nextSample(with: coverageMatrix)

                if shouldEndTest {
                    self.finalSampling()
                    self.testEnded = true
                }
                self.stateLock.unlock()
            }
            workQueue.async(execute: workItem)
        } else {
            updateProgress()
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
    public func deletedSamples() -> [ORKdBHLToneAudiometryDeletedSample] {
        // freq, level, originalIndex, response, deletionTimestamp
        return deleted.rows.map { deletedSample in
            let deletedSampleArray = Array(deletedSample)
            let sample = ORKdBHLToneAudiometryDeletedSample()
            sample.frequency = hz(deletedSampleArray[0])
            sample.level = deletedSampleArray[1]
            sample.channel = channel
            sample.originalIndex = Int(deletedSampleArray[2])
            sample.response = deletedSampleArray[3] == 0.0 ? false : true
            sample.deletionTimestamp = deletedSampleArray[4]
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
    @objc public func dropTrials(_ nTrialsToDrop: Int) {
        let history = stateHistory.dropLast(nTrialsToDrop - 1)
        stateHistory = Array(history)
        
        if let state = stateHistory.last {
            self.setState(state)
        }
    }
    
    func getCurrentState() -> ORKNewAudiometryState {
        stateLock.lock()
        let channel = self.channel
        
        let tones = xSample.rows.map {
            let row = Array($0)
            return ORKAudiometryStimulus(frequency: row[0], level: row[1], channel: channel)
        }
        let responses = ySample.rows.map {
            let row = Array($0)
            return row[0] == 1.0 ? true : false
        }
        
        let toneResponses = zip(tones, responses)
            .map { ($0, $1) }
        
        let deletedTones = Array(deleted.rows).map {
            let row = Array($0)
            let deletedTone = ORKdBHLToneAudiometryDeletedSample()
            deletedTone.frequency = row[0]
            deletedTone.level = row[1]
            deletedTone.channel = channel
            deletedTone.originalIndex = Int(row[2])
            deletedTone.response = row[3] == 0 ? false : true
            deletedTone.deletionTimestamp = row[4]

            return deletedTone
        }
        
        let state = ORKNewAudiometryState(currentTone: stimulus,
                                          responses: toneResponses,
                                          deletedTones: deletedTones,
                                          uncoveredInitialSamplingFrequencies: testFs.elements,
                                          previousAudiogram: previousAudiogram,
                                          resultUnitsTable: resultUnitsTable,
                                          resultUnit: resultUnit)
        stateLock.unlock()

        return state
    }
    
    func setState(_ state: ORKNewAudiometryState) {
        workItem.cancel()
        stateLock.lock()
        
        stimulus = state.currentTone
        testFs = state.uncoveredInitialSamplingFrequencies.asVector()
        xSample = Matrix(rows: state.responses.map { [$0.tone.frequency, $0.tone.level] })
        ySample = Matrix(rows: state.responses.map { [$0.response ? 1.0 : 0.0] })
        deleted = Matrix(rows: state.deletedTones.map { [$0.frequency, $0.level, Double($0.originalIndex), $0.response ? 0 : 1, $0.deletionTimestamp] })
        initialSamples = state.responses.map { $0.response }

        if testFs.isEmpty {
            let sampleFrequencies = xSample.getColumn(0).elements.map { round(hz($0)) }
            let firstNonInitialSample = sampleFrequencies.firstIndex { !allFrequencies.contains($0) }
            initialSamples = Array(initialSamples.prefix(upTo: firstNonInitialSample ?? initialSamples.count))
            initialSampleEnded = true
            
            if stimulus == nil {
                let coverageMatrix = self.checkCoverage()
                self.updateProgress(with: coverageMatrix)
                let shouldEndTest = !self.nextSample(with: coverageMatrix)

                if shouldEndTest {
                    self.lastProgress = 1.0
                    self.finalSampling()
                    self.testEnded = true
                }
            }
        } else {
            initialSampleEnded = false
            if let stateAudiogram = state.previousAudiogram, !stateAudiogram.isEmpty {
                previousAudiogram = stateAudiogram
            }
        }
        statusDidChange()
        
        resultUnit = state.resultUnit
        resultUnitsTable = state.resultUnitsTable
        
        stateLock.unlock()
    }

    func didSetPreviousAudiogram() {
        if !previousAudiogram.isEmpty, Set(previousAudiogram.keys).isSuperset(of: allFrequencies) {
            _ = nextInitialSampleFromAudiogram()
            resultUnitsTable.removeAll()
        }
    }
    
    func nextInitialSampleFromAudiogram() -> Bool {
        guard let freqPoint = testFs.first, !initialSampleEnded else {
            // No more frequencies left, finish the initial sampling
            initialSampleEnded = true
            return false
        }
        
        let upDown = [1000.0: 1, 2000.0: -1, 4000.0: 1, 8000.0: 1, 500.0: -1, 250.0: 1]
        let xSampleFreqs = xSample.getColumn(0).elements
        let freqPointHz = round(hz(freqPoint))
        let freqUpDown = upDown[freqPointHz]
        var dBHLPoint: Double
        
        if !xSampleFreqs.contains(freqPoint) { // First sample for freq
            // intial point to sample is up or down 10
            let firstdBHLPoint = (previousAudiogram[freqPointHz] ?? 0.0) + Double((freqUpDown ?? 0) * 10)
            dBHLPoint = min(max(firstdBHLPoint, minLevel), maxLevel)
        
            if !revFs.contains(freqPoint) {
                testFs.dropFirst()
            }
            
        } else if revFs.contains(freqPoint) { // also need reversal
            let responsesForFreq = zip(xSampleFreqs, ySample.elements)
                .filter { abs($0.0 - freqPoint) < 0.01 } // Check if it's equal ignoring fp errors
                .map { $0.1 }
            
            let negResp = responsesForFreq.contains(0)
            let posResp = responsesForFreq.contains(1)
            
            if (negResp && posResp) {
                testFs.dropFirst()
                return nextInitialSampleFromAudiogram()
            }
            
            // stepsize  = 20 if jumping over curve else set it to 10 below
            var stepSize = responsesForFreq.count <= 1 ? 20.0 : 10.0
            
            let positiveResponse = responsesForFreq.last == 1
            if (positiveResponse && freqUpDown == -1) || (!positiveResponse && freqUpDown == 1) {
                stepSize = 10.0
            }
            
            let lastdBHLPoint = xSample.getColumn(1).elements.last ?? 0
            if !positiveResponse {
                dBHLPoint = min(lastdBHLPoint + stepSize, maxLevel)
            } else {
                dBHLPoint = max(lastdBHLPoint - stepSize, minLevel)
            }
        } else {
            testFs.dropFirst()
            return nextInitialSampleFromAudiogram()
        }
        
        stimulus = ORKAudiometryStimulus(frequency: freqPointHz,
                                         level: dBHLPoint,
                                         channel: channel)
        return true
    }

    func nextInitialSample(skipReversalFrequencies: Bool = false) -> Bool {
        if !previousAudiogram.isEmpty {
            return nextInitialSampleFromAudiogram()
        }
        
        guard !testFs.isEmpty && !initialSampleEnded else {
            initialSampleEnded = true
            return false
        }

        let jumpF = bark(500)
        let freqPoint = testFs[0]
        
        let xSampleFreqs = xSample.getColumn(0).elements
        let xSampleLevels = xSample.getColumn(1).elements
        var dbHLPoint = xSampleLevels.last ?? initialLevel
        
        let ySample1k = zip(xSampleFreqs, ySample.elements)
            .filter { $0.0 == bark(1000) }
            .last?.1 ?? 0
        
        let dbHLPoint1k = zip(xSampleFreqs, xSampleLevels)
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
    
    func nextSample(with coverage: Matrix<Double>) -> Bool {
        // get coverage matrix and check stopping criteria
        var coverageMatrix = coverage
        if shouldStop(with: coverageMatrix) {
            return false
        }
        
        // check and remove outliers after 5 sampled points
        let sampledPoints = ySample.shape.rows - initialSamples.count
        if sampledPoints >= 5 {
            let outliersResult = removeOutlierFit(coverageMatrix, deleted)
            if !outliersResult.deleted.elements.isEmpty {
                deleted.appendRows(of: outliersResult.deleted)
                ySample = outliersResult.ySample
                xSample = outliersResult.xSample
                
                // update coverage matrix and check stopping criteria again
                coverageMatrix = checkCoverage()
                if shouldStop(with: coverageMatrix) {
                    return false
                }
            }
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

        let minFreq = allFrequencies.min() ?? 250
        let maxFreq = allFrequencies.max() ?? 8000
        let extraFrequencies = [3000.0, 6000.0]
        let upperSampleIndex = Double(30 - (allFrequencies.count - 2) - extraFrequencies.count - 1)
        let interpolatedFreqs = Interpolators.log2Interpolate(values: [minFreq, maxFreq],
                                                              atIndices: [0, upperSampleIndex])

        let frequenciesSimple = allFrequencies.sorted()
        var resultsSimple = [Double: Double]()
        for freq in frequenciesSimple {
            resultsSimple[freq] = Interpolators.interp1d(xValues: fitFreqs,
                                                   yValues: fitLevels,
                                                   xPoint: bark(freq))
        }
        
        let frequencies = Array(Set(interpolatedFreqs + allFrequencies + extraFrequencies)).sorted()
        for freq in (frequencies) {
            results[freq] = Interpolators.interp1d(xValues: fitFreqs,
                                                   yValues: fitLevels,
                                                   xPoint: bark(freq))
        }
        
        fitMatrix = zip(fitFreqs, fitLevels).reduce(into: [:]) {
            $0[String(format: "%.16lf", $1.0)] = $1.1
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
        let levelSpacing = 2.5

        for rowSlice in notCovered.rows {
            let row = Array(rowSlice)
            let dBRange = vDSP.linearInterpolate(values: [minLevel, maxLevel], atIndices: [0, (maxLevel - minLevel) / levelSpacing])
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
                newPoint[1] -= 1.5 * diff
            } else if numHeard < numUnheard {
                newPoint[1] += 1.5 * diff
            }
        }

        // clip point to dB range
        newPoint[1] = max(minLevel, min(newPoint[1], maxLevel))

        return newPoint
    }
    
    func checkCoverage(xWidth: Double = 2.2,
                       yWidth: Double = 12.5,
                       numHeardNeeded: Int = 2,
                       numUnheardNeeded: Int = 2) -> Matrix<Double> {
        
        // store results in matrix: point, numHeard, numNotHeard, yEst, covered
        var coverageMatrix = Matrix<Double>(elements: [], rows: 0, columns: 5)
        
        let freqRange = bark(allFrequencies.asVector())
        // rdar://112193144 ([Yodel-T1072] For CV: Increase granularity of dB range in checkCoverage function)
        let barkRange = vDSP.linearInterpolate(values: [freqRange.minimum(), freqRange.maximum()],
                                               atIndices: [0, 50])
        
        let xRange = (barkRange + [500, 1000, 2000, 3000, 4000, 6000].map(bark)).sorted()
        let specialFreqs1 = [250, 1000, 4000, 8000].map(bark)
        let specialFreqs2 = [500, 6000].map(bark)

        // loop frequency range
        for xPoint in xRange {
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
            let yMin = yEst - yWidth
            let yMax = yEst + yWidth
            let xMin: Double
            let xMax: Double
            
            if specialFreqs1.contains(xPoint) {
                xMin = xPoint - 1.2
                xMax = xPoint + 1.2
            } else if specialFreqs2.contains(xPoint) {
                xMin = xPoint - 1.6
                xMax = xPoint + 1.6
            } else {
                xMin = xPoint - xWidth
                xMax = xPoint + xWidth
            }
            
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
    
    func shouldStop(with coverageMatrix: Matrix<Double>) -> Bool {
        let covered = coverageMatrix.filterOnColumn(4) { $0 == 1 }
        let coverage = Float(covered.shape.rows) / Float(coverageMatrix.shape.rows)
        
        // check stopping criteria
        let hitStoppingCriteria = coverage >= 1.0
        let hitMaximumSampling = ySample.count >= maxSampleCount
        if hitStoppingCriteria || hitMaximumSampling {
            return true
        }
        return false
    }
    
    func removeOutlierFit(_ coverageMatrix: Matrix<Double>,
                          _ deleted: Matrix<Double>,
                          yDiff: Double = 4) -> (xSample: Matrix<Double>,
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
        let newXSample = xSample.filterRows(idxToDelete)
        let newYSample = ySample.filterRows(idxToDelete)
        let toDelete = xSample.gatherRows(idxToDelete)
            .appendingColumn(idxToDelete.map { Double($0 + deleted.count) }.asVector())
            .appendingColumn(ySample.gatherRows(idxToDelete).asVector()) // Add extra response for CV only
            .appendingColumn(.init(repeating: timestampProvider(), count: idxToDelete.count)) // Add extra deletion timestamp for CV only

        return (newXSample, newYSample, toDelete)
    }
}

@available(iOS 14, *)
extension ORKNewAudiometry {
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
        
        best_fit.clip(to: minLevel...maxLevel, along: .columns, withIndex: 1)
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
                  nu: Double = 10) -> Matrix<Double> {
        guard diagOnly else {
            let eye = Matrix.eye(x.shape.rows)
            let kernel = kernel(x, x, theta: theta, length: length)
            return kernel + (nu * eye)
        }
    
        let tmp = theta[0] ** 2 + nu
        
        let column = x.getColumn(1)
        var tmp1 = column.reshaped(rows: -1, columns: 1).multipliedByTransposed()
        tmp1.addInplace(theta[1] ** 2)
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
