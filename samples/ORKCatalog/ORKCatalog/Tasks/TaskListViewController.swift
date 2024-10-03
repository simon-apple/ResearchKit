/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.

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

import UIKit
import ResearchKit_Private
import ResearchKitUI

#if RK_APPLE_INTERNAL
import ResearchKitInternal
import ResearchKitInternal_Private
import SwiftUI
#endif


/**
    This example displays a catalog of tasks, each consisting of one or two steps,
    built using the ResearchKit framework. The `TaskListViewController` displays the
    available tasks in this catalog.

    When you tap a task, it is presented like a participant in a study might
    see it. After completing the task, you can see the results generated by
    the task by switching to the results tab.
*/
class TaskListViewController: UITableViewController, ORKTaskViewControllerDelegate {

    var waitStepViewController: ORKWaitStepViewController?
    var waitStepUpdateTimer: Timer?
    var waitStepProgress: CGFloat = 0.0
    #if RK_APPLE_INTERNAL
    var showInternalViewControllers = false
    #endif


    // In-memory store for taskViewController restoration data
    var restorationDataByTaskID: [String:Data] = [:]
    
    // MARK: Types
    
    enum TableViewCellIdentifier: String {
        case `default` = "Default"
    }
    
    // MARK: Properties
    
    /**
        When a task is completed, the `TaskListViewController` calls this closure
        with the created task.
    */
    var taskResultFinishedCompletionHandler: ((ORKResult) -> Void)?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.systemGroupedBackground
        // start-omit-internal-code
        writeHeartRateUITestData()
        // end-omit-internal-code
    }
    
    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return TaskListRow.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskListRow.sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TaskListRow.sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifier.default.rawValue, for: indexPath)
        
        let taskListRow = TaskListRow.sections[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        
        cell.textLabel!.text = "\(taskListRow)"
        cell.textLabel?.textColor = UIColor.label
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Present the task view controller that the user asked for.
        let taskListRow = TaskListRow.sections[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        #if RK_APPLE_INTERNAL
        if taskListRow == .studyPromoTask {
            let studyPromoViewController = StudyPromoViewController()
            studyPromoViewController.delegate = self
            self.present(studyPromoViewController, animated: true)
            return
        } else if taskListRow == .studySignPostStep {
            let label1 = UILabel()
            label1.text = "Sample Label 1"
            
            let label2 = UILabel()
            label2.text = "Sample Label 2"
            
            let hstack = UIStackView(arrangedSubviews: [label1, label2])
            hstack.axis = .vertical
            let customStep = ORKCustomStep(identifier: "testt", contentView: hstack)
            customStep.title = "My Title is here"
            customStep.text = "My Text is here"
            customStep.detailText = "Detail Text Here"
            customStep.iconImage = UIImage(systemName: "clock")
            
            let vc = ORKCustomStepViewController(step: customStep)
            vc.delegate = self
            present(vc, animated: true)
            return
        } else if taskListRow == .familyHistoryReviewTask {
            let reviewViewController = ORKFamilyHistoryReviewController(task: taskListRow.representedTask as! ORKNavigableOrderedTask, delegate: self, isCompleted: false, incompleteText: "Complete Family History Task")
            reviewViewController.modalPresentationStyle = .fullScreen
            present(reviewViewController, animated: true)
            return
        }
        
        // display internal tasks with ORKITaskViewController
        if indexPath.section == 5 {
            showInternalViewControllers = true
            displayInternalTaskViewController(taskListRow: taskListRow)
            return
        } else {
            showInternalViewControllers = false 
        }
        
        #endif
        
        displayTaskViewController(taskListRow: taskListRow)
    }
    
    func displayTaskViewController(taskListRow: TaskListRow) {
        // Create a task from the `TaskListRow` to present in the `ORKTaskViewController`.
        let task = taskListRow.representedTask
        
        /*
         Passing `nil` for the `taskRunUUID` lets the task view controller
         generate an identifier for this run of the task.
         */
        var taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        
        // Make sure we receive events from `taskViewController`.
        taskViewController.delegate = self
        
        // Assign a directory to store `taskViewController` output.
        taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let restorationData = restorationDataByTaskID[task.identifier] {
            
            // we have data we can use to recreate the state of a previous taskViewController
            taskViewController = ORKTaskViewController(task: task, restorationData: restorationData, delegate: self, error: nil)
        } else {
            
            // making a brand new taskViewController
            taskViewController = ORKTaskViewController(task: task, ongoingResult: nil, defaultResultSource: nil, delegate: self)

            // Assign a directory to store `taskViewController` output.
            taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        /*
         We present the task directly, but it is also possible to use segues.
         The task property of the task view controller can be set any time before
         the task view controller is presented.
         */
#if RK_APPLE_INTERNAL
        if #available(iOS 15.0, *),
           UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSwiftUIEnabled) {
            var researchKitView = ResearchTaskView(
                task: task,
                allowsNavigatingBackwards: true
            )
            let logger = Logger(subsystem: "ORKCatalog", category: "SwiftUI: TaskView")
            researchKitView.onResultChange = { result in
                logger.log("result has been updated to \(result)")
            }
            researchKitView.onStartStep = { startStep in
                logger.log("start step has loaded \(startStep)")
            }
            researchKitView.onFinishStep = { finishStep in
                logger.log("finish step has loaded \(finishStep)")
            }
            researchKitView.onLearnMoreTap = { learnMoreStep in
                logger.log("learn more button has been tapped \(learnMoreStep)")
            }
            researchKitView.onFinishTask = { [weak self] reason, result, error in
                self?.taskResultFinishedCompletionHandler?(result)
            }
            
            let swiftUITaskViewController = UIHostingController(rootView: researchKitView)
            present(swiftUITaskViewController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            present(taskViewController, animated: true)
        }
#else
        present(taskViewController, animated: true)
#endif
    }
    
#if RK_APPLE_INTERNAL
    func displayInternalTaskViewController(taskListRow: TaskListRow) {
        // Create a task from the `TaskListRow` to present in the `ORKTaskViewController`.
        let task = taskListRow.representedTask
        
        /*
         Passing `nil` for the `taskRunUUID` lets the task view controller
         generate an identifier for this run of the task.
         */
        var taskViewController = ORKITaskViewController(task: task, taskRun: nil)
        
        // Make sure we receive events from `taskViewController`.
        taskViewController.delegate = self
        taskViewController.internalDelegate = self
        
        // Assign a directory to store `taskViewController` output.
        taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if let restorationData = restorationDataByTaskID[task.identifier] {
            // we have data we can use to recreate the state of a previous taskViewController
            taskViewController = ORKITaskViewController(task: task, restorationData: restorationData, delegate: self, error: nil)
        } else {
            // making a brand new taskViewController
            taskViewController = ORKITaskViewController(task: task, ongoingResult: nil, defaultResultSource: nil, delegate: self)
            // Assign a directory to store `taskViewController` output.
            taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        /*
         We present the task directly, but it is also possible to use segues.
         The task property of the task view controller can be set any time before
         the task view controller is presented.
         */
        if #available(iOS 15.0, *),
           UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSwiftUIEnabled) {
            var researchKitView = ResearchTaskView(
                task: task,
                allowsNavigatingBackwards: true
            )
            let logger = Logger(subsystem: "ORKCatalog", category: "SwiftUI: TaskView")
            researchKitView.onResultChange = { result in
                logger.log("result has been updated to \(result)")
            }
            researchKitView.onStartStep = { startStep in
                logger.log("start step has loaded \(startStep)")
            }
            researchKitView.onFinishStep = { finishStep in
                logger.log("finish step has loaded \(finishStep)")
            }
            researchKitView.onLearnMoreTap = { learnMoreStep in
                logger.log("learn more button has been tapped \(learnMoreStep)")
            }
            researchKitView.onFinishTask = { [weak self] reason, result, error in
                self?.taskResultFinishedCompletionHandler?(result)
            }
            
            let swiftUITaskViewController = UIHostingController(rootView: researchKitView)
            present(swiftUITaskViewController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            present(taskViewController, animated: true)
        }
    }
    
    func presentReadOnlyVCIfNeeded(task: ORKTask?, result: ORKTaskResult) {
        if let task = task as? ORKOrderedTask {

            if task.identifier == String(describing: Identifier.readOnlyFormStepTask) {
                let readonlyVC = ORKReadOnlyReviewViewController(task: task, result: result, readOnlyStepType: .surveyStep, title: "Data", detailText: "If you'd like to make changes before sharing this data, visit Your Data", navTitle: "Demographics")
                self.navigationController?.pushViewController(readonlyVC, animated: true)
            } else if task.identifier == String(describing: Identifier.familyHistoryStep) {
                let readonlyVC = ORKReadOnlyReviewViewController(task: task, result: result, readOnlyStepType: .familyHistoryStep, title: "Data", detailText: "If you'd like to make changes before sharing this data, visit Your Data", navTitle: "Family Health History")
                self.navigationController?.pushViewController(readonlyVC, animated: true)
            }
            
        }
        
    }
#endif
    
    func storePDFIfConsentTaskDetectedIn(taskViewController: ORKTaskViewController) {
        guard taskViewController.task?.identifier == String(describing: Identifier.consentTask) else {
            return
        }
        
        guard let stepResult = taskViewController.result.result(forIdentifier: String(describing: Identifier.webViewStep)) as? ORKStepResult else {
            return
        }
        
        if let webViewStepResult = stepResult.results?.first as? ORKWebViewStepResult, let html = webViewStepResult.htmlWithSignature {
            let htmlFormatter = ORKHTMLPDFWriter()
            
            htmlFormatter.writePDF(fromHTML: html) { data, error in
               let pdfURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("consentTask")
                    .appendingPathExtension("pdf")
                try? data.write(to: pdfURL)
            }
        }
    }
    
    // MARK: ORKTaskViewControllerDelegate
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskFinishReason, error: Error?) {
        /*
            The `reason` passed to this method indicates why the task view
            controller finished: Did the user cancel, save, or actually complete
            the task; or was there an error?

            The actual result of the task is on the `result` property of the task
            view controller.
        */
        
        storePDFIfConsentTaskDetectedIn(taskViewController: taskViewController)
        taskResultFinishedCompletionHandler?(taskViewController.result)
        
        switch (reason) {
        case .saved:
            saveRestorationData(for: taskViewController);
            break;
            
        case .discarded:
            /* If the user chose to discard the edits, we also remove previous restorationData.
             This way, if the user launches the same task again, it'll behave like it's been
             launched for the first time.
             */
            resetRestorationData(for: taskViewController);
            break;

        case .completed, .earlyTermination, .failed:
            // For any other reason, we also reset restoration data
            resetRestorationData(for: taskViewController);
            break;

        default:
            break;
        }
        
#if RK_APPLE_INTERNAL
        taskViewController.dismiss(animated: true) {
            self.presentReadOnlyVCIfNeeded(task: taskViewController.task, result: taskViewController.result)
        }
#else
        taskViewController.dismiss(animated: true, completion: nil)
#endif
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        // Example data processing for the wait step.
        if stepViewController.step?.identifier == String(describing: Identifier.waitStepIndeterminate) ||
            stepViewController.step?.identifier == String(describing: Identifier.waitStep) ||
            stepViewController.step?.identifier == String(describing: Identifier.loginStep) {
            delay(5.0, closure: { () -> Void in
                if let stepViewController = stepViewController as? ORKWaitStepViewController {
                    stepViewController.goForward()
                }
            })
        } else if stepViewController.step?.identifier == String(describing: Identifier.waitStepDeterminate) {
            delay(1.0, closure: { () -> Void in
                if let stepViewController = stepViewController as? ORKWaitStepViewController {
                    self.waitStepViewController = stepViewController
                    self.waitStepProgress = 0.0
                    self.waitStepUpdateTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(TaskListViewController.updateProgressOfWaitStepViewController), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.waitStepUpdateTimer!, forMode: RunLoop.Mode.common)
                }
            })
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, learnMoreButtonPressedWith learnMoreStep: ORKLearnMoreInstructionStep, for stepViewController: ORKStepViewController) {
        //        FIXME: Temporary fix. This method should not be called if it is only used to present the learnMoreStepViewController, the stepViewController should present the learnMoreStepViewController.
        stepViewController.present(UINavigationController(rootViewController: ORKLearnMoreStepViewController(step: learnMoreStep)), animated: true) {
            
        }
    }
 
#if RK_APPLE_INTERNAL
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if showInternalViewControllers {
            return ORKInternalClassMapper.mappedStepViewController(for: step, from: taskViewController)
        }
        
        return nil 
    }
#endif

    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    func delay(_ delay: Double, closure: @escaping () -> Void ) {
        let delayTime = DispatchTime.now() + delay
        let dispatchWorkItem = DispatchWorkItem(block: closure)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: dispatchWorkItem)
    }
    
    @objc
    func updateProgressOfWaitStepViewController() {
        if let waitStepViewController = waitStepViewController {
            waitStepProgress += 0.01
            DispatchQueue.main.async(execute: { () -> Void in
                waitStepViewController.setProgress(self.waitStepProgress, animated: true)
            })
            if waitStepProgress < 1.0 {
                return
            } else {
                self.waitStepUpdateTimer?.invalidate()
                waitStepViewController.goForward()
                self.waitStepViewController = nil
            }
        } else {
            self.waitStepUpdateTimer?.invalidate()
        }
    }
    
    /* Once saved in-memory, the user can later bring up the same task and start off where they left off.
     This works only until the app relaunches since we don't save the restorationData to disk
     */
    func saveRestorationData(for taskViewController: ORKTaskViewController) {
        guard let taskID = taskViewController.task?.identifier else {
            return
        }
        
        restorationDataByTaskID[taskID] = taskViewController.restorationData
    }

    func resetRestorationData(for taskViewController: ORKTaskViewController) {
        guard let taskID = taskViewController.task?.identifier else {
            return
        }
        
        restorationDataByTaskID[taskID] = nil
    }

}

#if RK_APPLE_INTERNAL
extension TaskListViewController: ORKITaskViewControllerDelegate {
    // Refers to rdar://85344999 (Remove the learnmore workaround current present in customized completion steps to reduce inter-dependent approach with the Research App)
    func taskViewController(_ taskViewController: ORKTaskViewController, sensitiveURLLearnMoreButtonPressedWith sensitiveURLLearnMoreStep: ORKSensitiveURLLearnMoreInstructionStep, for stepViewController: ORKStepViewController) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, goToSettingsButtonPressedWith settingStatusStep: ORKSettingStatusStep, sensitiveURLString: String, applicationString: String) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

extension TaskListViewController: ORKStepViewControllerDelegate {
    func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
        stepViewController.dismiss(animated: true)
    }
    
    func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
        // pass
    }
    
    func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
        // pass
    }
    
    func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: Error) {
        // pass
    }
    
    
}


extension TaskListViewController: ORKFamilyHistoryReviewControllerDelegate {
    func familyHistoryReviewController(_ familyHistoryReviewController: ORKFamilyHistoryReviewController, didUpdate updatedResult: ORKTaskResult, source resultSource: ORKTaskResult) {
        // result was updated
    }
    
    func familyHistoryReviewControllerDidSelectIncompleteCell(_ familyHistoryReviewController: ORKFamilyHistoryReviewController) {
        // incomplete cell selected
        dismiss(animated: true)
    }
}

#endif

// start-omit-internal-code
// This class is used in UI tests to write HealthKit data
class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    var savedHeartRateSample: HKQuantitySample?
    private var heartRateType: HKQuantityType? {
        return HKQuantityType.quantityType(forIdentifier: .heartRate)
    }
    
    enum HealthKitManagerError: Error {
        case healthKitNotAvailable
        case heartRateTypeNotAvailable
        case authorizationFailed
        case dataWriteFailed
    }
    
    private init() {
    }
    
    func requestAuthorizationAndWriteHeartRateDate(bpm: Double, date: Date = Date(), completion: @escaping (Bool, Error?) -> Void) {
        
        if !HKHealthStore.isHealthDataAvailable() {
            completion(false, HealthKitManagerError.healthKitNotAvailable)
            return
        }
        
        guard let heartRateType = self.heartRateType else {
            completion(false, HealthKitManagerError.heartRateTypeNotAvailable)
            return
        }
        
        let typesToShare: Set<HKSampleType> = [heartRateType]
        let typesToRead: Set<HKSampleType> = [heartRateType]
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: bpm)
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] (authorized, error) in
            guard authorized else {
                completion(false, HealthKitManagerError.authorizationFailed)
                return
            }
            
            self?.healthStore.save(heartRateSample) { (success, error) in
                guard success else {
                    completion(false, HealthKitManagerError.dataWriteFailed)
                    return
                }
                completion(true, nil)
                self?.savedHeartRateSample = heartRateSample
            }
        }
    }
    
    func deleteHeartRateData(completion: @escaping (Bool, Error?) -> Void) {
        if let sample = savedHeartRateSample {
            healthStore.delete(sample) { (success, error) in
            completion(success, error)}
        } else {
            completion(false, nil)
        }
    }
}

private func writeHeartRateUITestData() {
    if ProcessInfo.processInfo.environment.keys.contains("WriteHealthKitUITestData") {
        guard let heartRateTestData = Double(ProcessInfo.processInfo.environment["WriteHealthKitUITestData"] ?? "") else {
            return
        }
        HealthKitManager.shared.requestAuthorizationAndWriteHeartRateDate(bpm: heartRateTestData) { (success, error) in
            guard success else {
                return
            }
        }
    }
}
// end-omit-internal-code
