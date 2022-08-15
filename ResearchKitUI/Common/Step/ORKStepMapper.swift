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

import os
import Foundation
import ResearchKit
import ResearchKitUI_Private
import UIKit

@objcMembers public class ORKStepMapper: NSObject {
    private static var lock = os_unfair_lock()
    
    private static var stepMap: [String: ((ORKStep, ORKResult?) -> ORKStepViewController)] = [
        "\(ORKCompletionStep.self)": { ORKCompletionStepViewController(step: $0, result: $1) },
        "\(ORKConsentReviewStep.self)": { ORKConsentReviewStepViewController(step: $0, result: $1) },
        "\(ORKConsentSharingStep.self)": { ORKConsentSharingStepViewController(step: $0, result: $1) },
        "\(ORKFormStep.self)": { ORKFormStepViewController(step: $0, result: $1) },
        "\(ORKImageCaptureStep.self)": { ORKImageCaptureStepViewController(step: $0, result: $1) },
        "\(ORKInstructionStep.self)": { ORKInstructionStepViewController(step: $0, result: $1) },
        "\(ORKLearnMoreInstructionStep.self)": { ORKLearnMoreStepViewController(step: $0, result: $1) },
        "\(ORKLoginStep.self)": { viewControllerFromStep($0, $1, ORKLoginStepViewController.self) },
        "\(ORKPDFViewerStep.self)": { ORKPDFViewerStepViewController(step: $0, result: $1) },
        "\(ORKPageStep.self)": { ORKPageStepViewController(step: $0, result: $1) },
        "\(ORKPasscodeStep.self)": { ORKPasscodeStepViewController(step: $0, result: $1) },
        "\(ORKQuestionStep.self)": { ORKFormStepViewController(step: $0, result: $1) },
        "\(ORKRequestPermissionsStep.self)": { ORKRequestPermissionsStepViewController(step: $0, result: $1) },
        "\(ORKReviewStep.self)": { ORKReviewStepViewController(step: $0, result: $1) },
        "\(ORKSecondaryTaskStep.self)": { ORKSecondaryTaskStepViewController(step: $0, result: $1) },
        "\(ORKSensitiveURLLearnMoreInstructionStep.self)": { ORKInstructionStepViewController(step: $0, result: $1) },
        "\(ORKSignatureStep.self)": { ORKSignatureStepViewController(step: $0, result: $1) },
        "\(ORKStep.self)": { ORKStepViewController(step: $0, result: $1) },
        "\(ORKTableStep.self)": { ORKTableStepViewController(step: $0, result: $1) },
        "\(ORKVerificationStep.self)": { viewControllerFromStep($0, $1, ORKVerificationStepViewController.self) },
        "\(ORKVideoCaptureStep.self)": { ORKVideoCaptureStepViewController(step: $0, result: $1) },
        "\(ORKVideoInstructionStep.self)": { ORKVideoInstructionStepViewController(step: $0, result: $1) },
        "\(ORKWaitStep.self)": { ORKWaitStepViewController(step: $0, result: $1) },
        "\(ORKWebViewStep.self)": { ORKWebViewStepViewController(step: $0, result: $1) },
    ]
    
    @objc(instantiateViewControllerForStep:andResult:)
    public static func instantiateViewController(step: ORKStep, result: ORKResult?) -> ORKStepViewController {
        let classString = "\(type(of: step))"
        os_unfair_lock_lock(&lock)
        guard let maker = stepMap[classString] else {
            fatalError("No view controller mapping for step \(classString)!")
        }
        os_unfair_lock_unlock(&lock)

        let vc = maker(step, result)
        
        vc.restorationIdentifier = step.identifier
        vc.restorationClass = type(of: vc)
        
        return vc
    }
    
    public static func registerClass(_ stepClass: AnyClass, withInstantiationBlock block: @escaping (ORKStep, ORKResult?) -> ORKStepViewController) {
        os_unfair_lock_lock(&lock)
        stepMap["\(stepClass)"] = block
        os_unfair_lock_unlock(&lock)
    }
}
