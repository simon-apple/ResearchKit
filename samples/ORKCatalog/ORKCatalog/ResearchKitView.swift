/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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

import ResearchKit
import SwiftUI

/// A SwiftUI adaptor for `ORKTaskViewController`.
@available(iOS 14.0, *)
struct ResearchTaskView: View {

    let task: ORKTask

    let allowsNavigatingBackwards: Bool

    var onResultChange: (ORKResult) -> Void = { _ in }
    
    var onStartStep: (ORKStep) -> Void = { _ in }

    var onFinishStep: (ORKStep) -> Void = { _ in }
    
    var onLearnMoreTap: (ORKStep) -> Void = { _ in }

    var onFinishTask: (ORKTaskViewControllerFinishReason, ORKTaskResult, Error?) -> Void = { _, _, _ in }

    var body: some View {

        // Use a wrapper instead of directly conforming to
        // `UIViewControllerRepresentable` in order to keep
        // this view platform agnostic. The ~~Representable
        // protocols are platform dependent.
        TaskViewWrapper(
            task: task,
            allowsNavigatingBackwards: allowsNavigatingBackwards,
            onResultChange: onResultChange,
            onStartStep: onStartStep,
            onFinishStep: onFinishStep,
            onLearnMoreTap: onLearnMoreTap,
            onFinishTask: onFinishTask
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

fileprivate struct TaskViewWrapper: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    private var presentation
    
    let task: ORKTask

    var allowsNavigatingBackwards: Bool

    var onResultChange: (ORKResult) -> Void

    var onStartStep: (ORKStep) -> Void

    var onFinishStep: (ORKStep) -> Void

    var onLearnMoreTap: (ORKStep) -> Void

    var onFinishTask: (ORKTaskViewControllerFinishReason, ORKTaskResult, Error?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            allowsNavigatingBackwards: allowsNavigatingBackwards,
            dismiss: { presentation.wrappedValue.dismiss() },
            onResultChange: onResultChange,
            onStartStep: onStartStep,
            onFinishStep: onFinishStep,
            onLearnMoreTap: onLearnMoreTap,
            onFinishTask: onFinishTask)
    }
        
    func updateUIViewController(
        _ uiViewController: WrapperViewController<ORKTaskViewController>,
        context: Context) {

        // It's possible that this view struct was recreated with a new RK task.
        // RK doesn't offer a good way to swap out the old task for the new one after
        // an `ORKTaskViewController` has already been presented. The best we can do
        // is recreate the entire view controller. This is an expensive operation, so
        // we only do it when the task has changed.
        if
            let oldTask = uiViewController.wrapped?.task,
            !oldTask.isEqual(task)
        {
            let taskViewController = makeTaskViewController(task: task, context: context)
            
            if let currentStepViewController = taskViewController.currentStepViewController {
                ORKStepViewControllerHelpers.customizeNavigationBarButtonItems(stepViewController: currentStepViewController, allowsNavigatingBackwards: allowsNavigatingBackwards)
            }
     
            if let step = taskViewController.currentStepViewController?.step {
                onStartStep(step)
            }
            
            uiViewController.wrap(viewController: taskViewController)
        }

        context.coordinator.dismiss = { presentation.wrappedValue.dismiss() }
        context.coordinator.onStartStep = onStartStep
        context.coordinator.allowsNavigatingBackwards = allowsNavigatingBackwards
        context.coordinator.onResultChange = onResultChange
        context.coordinator.onFinishStep = onFinishStep
        context.coordinator.onFinishTask = onFinishTask
    }
    
    func makeUIViewController(context: Context) -> WrapperViewController<ORKTaskViewController> {
        let wrapper = WrapperViewController<ORKTaskViewController>()
        let taskController = makeTaskViewController(task: task, context: context)
        wrapper.wrap(viewController: taskController)
        return wrapper
    }
    
    private func makeTaskViewController(
        task: ORKTask,
        context: Context
    ) -> ORKTaskViewController {
        let taskController = ORKTaskViewController(task: task, taskRun: nil)
        taskController.outputDirectory = preferredOutputDirectory()
        taskController.delegate = context.coordinator
        taskController.discardable = true
        return taskController
    }

    private func preferredOutputDirectory() -> URL {
         return FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            .first!
            .appendingPathComponent(
                "ResearchKit",
                isDirectory: true
            )
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {

        var allowsNavigatingBackwards: Bool

        var dismiss: () -> Void
        
        var onResultChange: (ORKResult) -> Void

        var onStartStep: (ORKStep) -> Void

        var onFinishStep: (ORKStep) -> Void

        var onFinishTask: (ORKTaskViewControllerFinishReason, ORKTaskResult, Error?) -> Void

        var onLearnMoreTap: (ORKStep) -> Void

        init(allowsNavigatingBackwards: Bool,
             dismiss: @escaping () -> Void,
             onResultChange: @escaping (ORKResult) -> Void,
             onStartStep: @escaping (ORKStep) -> Void,
             onFinishStep: @escaping (ORKStep) -> Void,
             onLearnMoreTap: @escaping (ORKStep) -> Void,
             onFinishTask: @escaping (
                ORKTaskViewControllerFinishReason, ORKTaskResult, Error?
             )
             -> Void
        ) {
            self.allowsNavigatingBackwards = allowsNavigatingBackwards
            self.dismiss = dismiss
            self.onResultChange = onResultChange
            self.onStartStep = onStartStep
            self.onFinishStep = onFinishStep
            self.onLearnMoreTap = onLearnMoreTap
            self.onFinishTask = onFinishTask
        }

        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didFinishWith reason: ORKTaskViewControllerFinishReason,
            error: Error?) {

            // Using `taskViewController.dismiss()` fails to update the
            // $isPresented binding value, so we have to pass in a dismiss()
            // closure provided by SwiftUI instead of using UIKit's.
            dismiss()
            onFinishTask(reason, taskViewController.result, error)
        }

        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            stepViewControllerWillAppear stepViewController: ORKStepViewController) {

              ORKStepViewControllerHelpers.customizeNavigationBarButtonItems(stepViewController: stepViewController, allowsNavigatingBackwards: allowsNavigatingBackwards)

            if let step = stepViewController.step {
                onStartStep(step)
            }
        }

        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            stepViewControllerWillDisappear stepViewController: ORKStepViewController,
            navigationDirection direction: ORKStepViewControllerNavigationDirection) {

            if let step = stepViewController.step, direction == .forward {
                onFinishStep(step)
            }
        }
        
        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didChange result: ORKTaskResult) {
            onResultChange(result)
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, learnMoreButtonPressedWith learnMoreStep: ORKLearnMoreInstructionStep, for stepViewController: ORKStepViewController) {
            onLearnMoreTap(learnMoreStep)
        }
    }
}

fileprivate struct ORKStepViewControllerHelpers {
    static func customizeNavigationBarButtonItems(stepViewController: ORKStepViewController,
                                                  allowsNavigatingBackwards: Bool) {
        if !allowsNavigatingBackwards {
            stepViewController.backButtonItem = UIBarButtonItem()
        } else {
            stepViewController.backButtonItem = nil
        }
    }
}


@available(iOS 14.0, *)
struct ResearchKitView_Previews: PreviewProvider {
    static func createSampleTask() -> ORKOrderedTask {
        let completionStep = ORKCompletionStep(identifier: "id1")
        completionStep.text = "You're done!"

        let formStep = ORKFormStep(identifier: "id2")
        formStep.formItems = [
            ORKFormItem(identifier: "id3", text: "What is Your Name?", answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil ))
        ]

        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = true
        answerFormat.maximumLength = 280

        let task =  ORKOrderedTask(identifier: "", steps: [ORKQuestionStep(identifier: "id4", title: "Hello", question: "Your Question here.", answer: answerFormat), formStep,completionStep] )
            return task
    }

    static var previews: some View {
        ResearchTaskView(
             task: ResearchKitView_Previews.createSampleTask(),
             allowsNavigatingBackwards: true
        )
    }
}
