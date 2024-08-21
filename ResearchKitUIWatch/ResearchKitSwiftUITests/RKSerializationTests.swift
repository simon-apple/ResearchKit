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

@testable import ResearchKitUI_Watch_
@testable import ResearchKit
import Testing

struct RKSerializationTests {

    @Test func extractUUIDFromString() async throws {
        let headerIDString = "50f9dbfb-f78b-4615-a7d4-bfededec531b-header"
        let cleanID = RKAdapter.test_extractUUID(headerIDString)
        #expect(cleanID == "50f9dbfb-f78b-4615-a7d4-bfededec531b")

        let stepIDString = "step-a0a9f8c0-5c00-11e9-8cf2-af4fadae911f"
        let cleanStepID = RKAdapter.test_extractUUID(stepIDString)
        #expect(cleanStepID == "a0a9f8c0-5c00-11e9-8cf2-af4fadae911f")
    }

    @Test func hasMatchingIdentifier() async throws {
        let headerIDString = "50f9dbfb-f78b-4615-a7d4-bfededec531b-header"
        let regularIDString = "50f9dbfb-f78b-4615-a7d4-bfededec531b"

        #expect(RKAdapter.test_hasMatchingIdentifiers(firstIdentifier: headerIDString, secondIdentifier: regularIDString) == true)
    }

    @Test func groupItems() async throws {
        let headerItem = ORKFormItem(
            identifier: "eed4f63a-e7da-488f-9118-f1a3d2a62132-header",
            text: "what is your Zip Code?",
            answerFormat: nil
        )

        let secondaryItem =  ORKFormItem(
            identifier: "eed4f63a-e7da-488f-9118-f1a3d2a62132",
            text: nil,
            answerFormat: ORKAnswerFormat.textAnswerFormat()
        )
        secondaryItem.placeholder = "Add ZIP code"

        let middleItem = ORKFormItem(
            identifier: "eed4f63a-e7da-488f-9118-f1a3d2a62134",
            text: "what is your DOB?",
            answerFormat: ORKAnswerFormat.dateAnswerFormat()
        )

        let headerItem2 = ORKFormItem(
            identifier: "eed4f63a-e7da-488f-9118-f1a3d2a62133-header",
            text: "What is your Height?",
            answerFormat: nil
        )

        let secondaryItem2 =  ORKFormItem(
            identifier: "eed4f63a-e7da-488f-9118-f1a3d2a62133",
            text: nil,
            answerFormat: ORKAnswerFormat.heightAnswerFormat()
        )
        secondaryItem2.placeholder = "Add Height"

        let groupedItems = RKAdapter.test_groupItems([headerItem, secondaryItem, middleItem, headerItem2, secondaryItem2])
        #expect(groupedItems.count == 3)

        #expect(groupedItems.first?.text == headerItem.text)
        #expect(groupedItems.first?.placeholder == secondaryItem.placeholder)

        #expect(groupedItems.last?.text == headerItem2.text)
        #expect(groupedItems.last?.placeholder == secondaryItem2.placeholder)
    }

}
