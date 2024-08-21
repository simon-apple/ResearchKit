//
//  RKSerializationTests.swift
//  ResearchKitSwiftUITests
//
//  Created by Johnny Hicks on 8/20/24.
//
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
