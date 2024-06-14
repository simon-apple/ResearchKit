/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

import Foundation

// TODO: - rdar://129806620 (Decide if FormRow should be Internal or Public)
/// Enumeration to cover all the different question types for FormStep
public enum FormRow: Identifiable {
    case multipleChoiceRow(MultipleChoiceQuestion)
    case doubleSliderRow(ScaleSliderQuestion<Double>)
    case intSliderRow(ScaleSliderQuestion<Int>)
    case textSliderStep(ScaleSliderQuestion<MultipleChoiceOption>)
    case textRow(TextQuestion)

    public var id: String {
        switch self {
        case .multipleChoiceRow(let multipleChoiceValue):
            multipleChoiceValue.id
        case .doubleSliderRow(let doubleSlider):
            doubleSlider.id
        case .intSliderRow(let intSlider):
            intSlider.id
        case .textSliderStep(let textSlider):
            textSlider.id
        case .textRow(let textValue):
            textValue.id
        }
    }

    var title: String {
        let title: String
        switch self {
        case .multipleChoiceRow(let multipleChoiceValue):
            title = multipleChoiceValue.title ?? ""
        case .doubleSliderRow(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        case .intSliderRow(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        case .textSliderStep(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        case .textRow(let textValue):
            title = textValue.title
        }
        return title
    }
}
