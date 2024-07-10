//  OnboardingUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/13/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class OnboardingUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
        /// Start with clean state. Reset authorization status for health and location
        if #available(iOS 14.0, *) {
            app.resetAuthorizationStatus(for: .health)
        }
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false {
            return
        }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    /// rdar://tsc/21847968 ([Onboarding] Eligibility Task Example)
    /// Navigable Ordered Task
    func testEligibilitySurvey() {
        tasksList
            .selectTaskByName(Task.eligibilityTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verify(.title)
            .verify(.text)
            .verify(.detailText)
            .tap(.continueButton)
        
        let formStep = FormStepScreen(itemIds: ["eligibilityFormItem01", "eligibilityFormItem02", "eligibilityFormItem03"])
        
        formStep
            .verify(.continueButton, isEnabled: false)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[1], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 1)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        // Eligible step
        completionStep
            .verify(.title)
            .verify(.detailText)
            .verifyImage(exists: true) // blue check mark success
            .verify(.continueButton, isEnabled: true)
            .tap(.backButton)
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 0)
            .tap(.continueButton)
        // Ineligible step
        completionStep
            .verify(.title)
            .verify(.detailText)
            .verifyImage(exists: false)
            .tap(.continueButton)
    }
    
    ///rdar://tsc/21847968 ([Onboarding] Eligibility Task Example)
    /// Navigable Ordered Task
    /// TODO: rdar://117821622 (Add localization support for UI Tests)
    func testEligibilitySurveyResultLabels() {
        tasksList
            .selectTaskByName(Task.eligibilityTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.continueButton)
        
        let formStep = FormStepScreen(itemIds: ["eligibilityFormItem01", "eligibilityFormItem02", "eligibilityFormItem03"])
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[1], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 1)
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        // Eligible step
            .verifyImageLabel(expectedAXLabel: "Illustration of a check mark in a blue circle conveying success")
            .verifyLabel(.detailText, expectedLabel: "You are eligible to join the study")
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.backButton)
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 0)
            .tap(.continueButton)
        completionStep
        // Ineligible step
            .verifyLabel(.detailText, expectedLabel: "You are ineligible to join the study")
            .tap(.continueButton)
    }
    
    // MARK: - Consent UI Tests
    
    /**
     Navigates through all steps in "Consent Task"
     - parameter verifyElements: adds verifications of ui elements 
     */
    private func obtainConsentViaConsentTask(verifyElements: Bool) {
        tasksList
            .selectTaskByName(Task.consentTask.description)
        
        // First instruction step
        let instructionStep = InstructionStepScreen()
            .tap(.continueButton)
        // Second instruction step
        instructionStep
            .tap(.continueButton)
        
        let webView = WebViewStepScreen()
        webView.verifyView() // Wait for web view to load
        app.swipeUp() // Accelerate scrolling up to signature view, a preparatory step for next method
        webView.scrollUpToSignatureView()
        if verifyElements {
            webView.verify(.continueButton, isEnabled: false)
        }
        webView.drawSignature()
        if verifyElements {
            webView.verify(.continueButton, isEnabled: true)
        }
        webView.tap(.continueButton)
        
        let informedConsentSharingFormStep = FormStepScreen()
        let formItemId = "TextChoiceFormItem"
        informedConsentSharingFormStep.verifyStepView()
        if verifyElements {
            informedConsentSharingFormStep
                .verify(.title)
                .verify(.text)
                .verify(.continueButton, isEnabled: true)
                .verify(.skipButton, isEnabled: true)
                .verifySingleQuestionTitleExists()
        }
        informedConsentSharingFormStep
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: 0)
            .tap(.continueButton)
        
        let healthDataRequestStep = RequestPermissionsStepScreen()
        let permissionButtonIndex = 0
        healthDataRequestStep
            .verifyStepView()
            .tapPermissionButton(atIndex: permissionButtonIndex) // Triggers alert for granting access
        let healthAccessScreen = HealthAccess()
        healthAccessScreen
            .verifyHealthAuthorizationView(exists: true)
            .verifyAllowButton(isEnabled: false)
            .tapAllowAllCell()
            .verifyAllowButton(isEnabled: true)
            .tapAllowButton()
        
        if verifyElements {
            healthDataRequestStep.verifyPermissionButtonLabelExists(atIndex: permissionButtonIndex, label: .labelConnected)
        }
        healthDataRequestStep
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        completionStep
            .tap(.continueButton)
    }
    
    /// rdar://tsc/33600824 ([Onboarding] Consent Task) - Happy Path
    func testConsentTask() throws {
        if isRunningInXcodeCloud && !isRunningOnSimulator {
            try XCTSkipIf(true, "Skipping this test when running in Xcode Cloud environment on device compute devices due to this issue: rdar://130824888 (Health Authorization Error and Health Access screen won't trigger in XCUITests - Occurs only on skywagon device compute devices)")
        }
        obtainConsentViaConsentTask(verifyElements: true)
    }
    
    /// rdar://tsc/33600824 ([Onboarding] Consent Task) - Negative Path
    func testConsentTaskClearSignature() {
        tasksList
            .selectTaskByName(Task.consentTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.continueButton)
        instructionStep
            .tap(.continueButton)
        
        let webView = WebViewStepScreen()
        webView
            .verifyView()
        app.swipeUp() // Accelerate scrolling up, a preparatory step for next method
        webView
            .scrollUpToSignatureView()
            .verify(.continueButton, isEnabled: false)
            .drawSignature()
            .tapClearSignature()
            .verify(.continueButton, isEnabled: false)
            .drawSignature()
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let informedConsentSharingFormStep = FormStepScreen()
        informedConsentSharingFormStep
            .cancelTask()
    }
    
    /// rdar://tsc/33600824 ([Onboarding] Consent Task)
    func testConsentContentExists() {
        tasksList
            .selectTaskByName(Task.consentTask.description)
        
        let instructionStep = InstructionStepScreen()
        let step1Title = instructionStep.getElementLabel(.title)
        let step1DetailText = instructionStep.getElementLabel(.detailText)
        instructionStep
            .tap(.continueButton)
        instructionStep
            .verifyStepView()
        let step2Title = instructionStep.getElementLabel(.title)
        let bodyItemsLabels = instructionStep.getBodyItemsLabels()
        
        instructionStep
            .tap(.continueButton)
        
        var consentContent = [String]()
        consentContent.append(step1Title)
        consentContent.append(step1DetailText)
        consentContent.append(step2Title)
        consentContent += bodyItemsLabels
        
        let webView = WebViewStepScreen()
        webView
            .verifyView()
            .verifyWebViewLabelsExist(expectedLabels: consentContent)
            .verifyNumOfImages(expectedCount: 2)
    }
    
    func testConsentDocumentReview() throws {
        if isRunningInXcodeCloud && !isRunningOnSimulator {
            try XCTSkipIf(true, "Skipping this test when running in Xcode Cloud environment on device compute devices due to this issue: rdar://130824888 (Health Authorization Error and Health Access screen won't trigger in XCUITests - Occurs only on skywagon device compute devices)")
        }
        
        // First we need to obtain consent in order to view PDF
        obtainConsentViaConsentTask(verifyElements: false)
        
        tasksList
            .selectTaskByName(Task.consentDoc.description)
        
        let pdfStep = PDFViewerStepScreen()
        
        test("Verify initial state of PDF Viewer Step") {
            pdfStep
                .verifyStepView()
                .verify(.showPDFThumbnailActionButton, exists: true)
                .verify(.annotationActionButton, exists: true)
                .verify(.showSearchActionButton, exists: true)
                .verify(.shareActionButton, exists: true)
                .verify(.continueButton, isEnabled: true)
        }
        
        test("Verify Thumbnail Action Button") {
            pdfStep.tap(.showPDFThumbnailActionButton)
            sleep(5) // Allow view to settle
            pdfStep
                .tap(.hidePDFThumbnailActionButton)
        }
        
        test("Verify Annotation Action Button") {
            pdfStep
                .tap(.annotationActionButton)
                .verify(.clearButton, exists: true)
                .verify(.applyButton, exists: true)
                .drawLine()
                .tap(.clearButton)
                .drawLine()
                .tap(.applyButton)
                .tap(.exitButton)
        }
        
        test("Verify Search Action Button") {
            pdfStep
                .tap(.showSearchActionButton)
                .enterTextInSearchField("Info")
                .tap(.hideSearchActionButton)
                .verifySearchField(exists: false)
            
                .tap(.shareActionButton)
                .verifyPopUpTitle(displayed: true)
                .closePopUp()
        }
        
        let text = "Welcome! \nThank you for joining our study. Tap Next to learn more before signing up. \nBefore You Join \nThe study will ask you to share some of your Health data. You will be asked to complete various tasks over the duration of the study. Before joining, we will ask you to sign an informed consent document. Your data is kept private and secure. \n"
        
        test("Verify Text Exists") {
            pdfStep
                .verifyLabelExist(expectedText: text)
        }
        
        test("Verify Text is Scrollable") {
            pdfStep.verifyValueExists(expectedValue: "0%")
            app.swipeUp()
            sleep(5) // Allow view to settle
            pdfStep.verifyValueExists(expectedValue: "100%")
        }
        
        pdfStep
            .tap(.continueButton)
    }
    
    // MARK: - Login, Account Creation, Passcode UI Tests
    
    /// rdar://tsc/21847972 ([Onboarding] Login) - Happy Path
    func testLogin() {
        tasksList
            .selectTaskByName(Task.login.description)
        
        let loginStep = FormStepScreen()
        let emailFormItemId = "ORKLoginFormItemEmail"
        let passwordFormItemId = "ORKLoginFormItemPassword"
        let validEmail = Answers.exampleValidEmail
        let password = Answers.exampleTextPassword
        
        loginStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true) // Skip button has "Forgot Password" label
            .verify(.continueButton, isEnabled: false)
            .verifySingleQuestionTitleExists()
        
        loginStep
            .selectFormItemCell(withID: emailFormItemId)
            .answerTextQuestion(text: validEmail, dismissKeyboard: true)
            .selectFormItemCell(withID: passwordFormItemId, atIndex: 1)
            .answerTextQuestion(text: password, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.skipButton) // Tap "Forgot Password" button
        
            .verifyAlert(exists: true) // "Forgot password?" alert title
            .verify(.continueButton, isHittable: false)
            .tapAlertFirstButton() // There is only one button: "OK"
            .verifyAlert(exists: false)
        
            .verifyContinueButtonLabel(expectedLabel: .login) // TODO: rdar://117821622 (Add localization support for UI Tests)
            .tap(.continueButton) // Continue button has "Login" label
        
        let step = WaitStepScreen()
        step
            .verifyStepView()
            .verify(.title)
            .verify(.text)
            .verifyActivityIndicator(exists: true)
            .verifyActivityIndicatorValue(expectedValue: "1")
        
        step.cancelTask()
    }
    
    /// rdar://tsc/21847972 ([Onboarding] Login) - Negative Path
    func testLoginInvalid() {
        tasksList
            .selectTaskByName(Task.login.description)
        
        let loginStep = FormStepScreen()
        let emailFormItemId = "ORKLoginFormItemEmail"
        let passwordFormItemId = "ORKLoginFormItemPassword"
        let validEmail = Answers.exampleValidEmail
        let password = Answers.exampleTextPassword
        let emailElements = validEmail.split(separator: "@").map(String.init)
        let username = emailElements[0]
        let domain = "@" + emailElements[1]
        
        loginStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: false)
            .verifySingleQuestionTitleExists()
        
        test("Verify invalid email address error message") {
            loginStep
                .selectFormItemCell(withID: emailFormItemId)
                .answerTextQuestion(text: username, dismissKeyboard: true)
                .verifyErrorMessage(exists: true, withId: emailFormItemId, expectedMessage: " Invalid email address") // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
                .selectFormItemCell(withID: passwordFormItemId, atIndex: 1)
                .answerTextQuestion(text: password, dismissKeyboard: true)
                .verify(.continueButton, isEnabled: false)
        }
        
        test("Enter valid email address after entering invalid email address") {
            loginStep
                .selectFormItemCell(withID: emailFormItemId)
                .answerTextQuestion(text: domain, dismissKeyboard: true) // Add domain email part
                .verify(.continueButton, isEnabled: true)
        }
        
        loginStep
            .tap(.cancelButton)
    }
    
    /// rdar://tsc/21847973 ([Onboarding] Passcode Creation) - Happy Path
    func testPasscodeCreation() {
        tasksList
            .selectTaskByName(Task.passcode.description)
        
        let passcodeStep = PasscodeStepScreen()
        let passcode = 1111
        passcodeStep
            .verifyImage(exists: true)
        Keyboards.enterNumber(passcode)
        passcodeStep
            .verifyAlert(exists: false)
        Keyboards.enterNumber(passcode)
    }
    
    /// rdar://tsc/21847973 ([Onboarding] Passcode Creation) - Negative Path
    func testPasscodeCreationInvalid() {
        tasksList
            .selectTaskByName(Task.passcode.description)
        
        let passcodeStep = PasscodeStepScreen()
        let passcode = 1111
        let invalidPasscode = 1112
        
        Keyboards.enterNumber(passcode)
        Keyboards.enterNumber(invalidPasscode)
        
        passcodeStep
            .verifyAlert(exists: true)
            .tapAlertFirstButton()
        
        Keyboards.enterNumber(passcode)
        Keyboards.enterNumber(passcode)
        
        passcodeStep
            .verifyAlert(exists: false)
    }
    
    /// rdar://tsc/21847971 ([Onboarding] Account Creation) - Happy Path
    func testAccountCreation() {
        tasksList
            .selectTaskByName(Task.accountCreation.description)
        
        let registrationStep = FormStepScreen()
        let emailFormItemId = "ORKRegistrationFormItemEmail"
        let confirmPasswordFormItemId = "ORKRegistrationFormItemConfirmPassword"
        
        let givenNameFormItemId = "ORKRegistrationFormItemGivenName"
        let familyNameFormItemId = "ORKRegistrationFormItemFamilyName"
        let genderFormItemId = "ORKRegistrationFormItemGender"
        let dobFormItemId = "ORKRegistrationFormItemDOB"
        let phoneNumberFormItemId = "ORKRegistrationFormItemPhoneNumber"
        
        let validEmail = Answers.exampleValidEmail
        // Splitting password to alphabetic and numeric parts as we need to change keyboard type between them
        let passwordAlphabeticPart = Answers.passwordAlphabeticPart
        let passwordNumericPart = Answers.passwordNumericPart
        
        registrationStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, exists: false)
            .verify(.continueButton, isEnabled: false)
        
        test("Verify email field") {
            registrationStep
                .selectFormItemCell(withID: emailFormItemId)
                .answerTextQuestion(text: validEmail, dismissKeyboard: true)
        }
        
        test("Verify password field") {
            // registrationStep.selectFormItemCell(withID: "ORKRegistrationFormItemPassword", atIndex: 1) // Note: No need to select form item due to autofocus. Keeping it here in case autofocus behavior changes going forward
            registrationStep.answerTextQuestion(text: passwordAlphabeticPart, dismissKeyboard: false)
            // In order to enter numbers we need to switch to numeric keyboard
            Keyboards.switchKeyboardType() // Switch to numeric
            registrationStep.answerIntegerQuestion(number: passwordNumericPart)
        }
        
        test("Verify password confirmation field") {
            registrationStep
                .selectFormItemCell(withID: confirmPasswordFormItemId, atIndex: 2)
                .answerTextQuestion(text: passwordAlphabeticPart, dismissKeyboard: false)
            Keyboards.switchKeyboardType() // Switch to numeric
            registrationStep
                .selectFormItemCell(withID: confirmPasswordFormItemId,  atIndex: 2)
                .answerIntegerQuestion(number: passwordNumericPart, dismissKeyboard: true)
        }
        
        registrationStep
            .selectFormItemCell(withID: givenNameFormItemId)
            .answerTextQuestion(text: "John", dismissKeyboard: true)
        
        registrationStep
            .selectFormItemCell(withID: familyNameFormItemId, atIndex: 1)
            .answerTextQuestion(text: "Appleseed", dismissKeyboard: true)
        
        registrationStep
            .selectFormItemCell(withID: genderFormItemId, atIndex: 2)
            .answerPickerValueChoiceQuestion(value: "Male", dismissPicker: true)
        
        registrationStep
            .selectFormItemCell(withID: dobFormItemId, atIndex: 3)
            .answerDateQuestion(year: "1978", month: "December", day: "25", dismissPicker: true)
        
        test("Verify phone number field") {
            registrationStep
                .selectFormItemCell(withID: phoneNumberFormItemId, atIndex: 4)
            Keyboards.tapShiftKey() // Switch to symbols
            registrationStep
                .answerTextQuestion(text: "+", dismissKeyboard: false)
            Keyboards.tapShiftKey() // Switch back to numeric
            registrationStep
                .answerTextQuestion(text: "1")
            Keyboards.tapSpace()
            registrationStep.answerTextQuestion(text: "(555)")
            Keyboards.tapSpace()
            registrationStep.answerTextQuestion(text: "555")
            Keyboards.tapSpace()
            registrationStep
                .answerTextQuestion(text: "5555", dismissKeyboard: true)
                .tap(.continueButton)
        }
        
        sleep(5) // Wait for wait step to end
        
        let verificationStep = VerificationStepScreen()
        verificationStep
            .verifyStepView()
            .tapResendEmailButton() // "Resend Verification Email" Button
            .verifyAlert(exists: true) // "Resend Verification Email" alert
            .tapAlertFirstButton() // There is only one button "OK"
        
        verificationStep
            .tapCancelButton()
            .tapDiscardResultsButton()
    }
    
    /// rdar://tsc/21847971 ([Onboarding] Account Creation) - Negative Path
    func testAccountCreationInvalid() {
        tasksList
            .selectTaskByName(Task.accountCreation.description)
        
        let registrationStep = FormStepScreen()
        let emailFormItemId = "ORKRegistrationFormItemEmail"
        let passwordFormItemId = "ORKRegistrationFormItemPassword"
        let confirmPasswordFormItemId = "ORKRegistrationFormItemConfirmPassword"
        let validEmail = Answers.exampleValidEmail
        let emailElements = validEmail.split(separator: "@").map(String.init)
        let username = emailElements[0]
        let domain = "@" + emailElements[1]
        // Splitting password to alphabetic and numeric parts as we need to change keyboard type between them
        let passwordAlphabeticPart = Answers.passwordAlphabeticPart
        let passwordNumericPart = Answers.passwordNumericPart
        
        test("Verify email field negative testing") {
            registrationStep
                .selectFormItemCell(withID: emailFormItemId)
                .answerTextQuestion(text: username, dismissKeyboard: true)
                .verifyErrorMessage(exists: true, withId: emailFormItemId, expectedMessage: " Invalid email address") // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
                .selectFormItemCell(withID: emailFormItemId)
                .answerTextQuestion(text: domain, dismissKeyboard: true)
                .verifyErrorMessage(exists: false, withId: emailFormItemId, expectedMessage: " Invalid email address")
        }
        
        test("Verify password field negative testing") {
            let errorMessage = " A valid password must be 4 to 8 characters long and include at least one numeric character." // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
            // registrationStep.selectFormItemCell(withID: "ORKRegistrationFormItemPassword", atIndex: 1) // Note: No need to select form item due to autofocus. Keeping it here in case autofocus behavior changes going forward
            registrationStep
                .answerTextQuestion(text: passwordAlphabeticPart, dismissKeyboard: true)
                .verifyErrorMessage(exists: true, withId: passwordFormItemId, atIndex: 1, expectedMessage: errorMessage)
            registrationStep
                .selectFormItemCell(withID: passwordFormItemId, atIndex: 1)
            Keyboards.deleteValue(characterCount: passwordAlphabeticPart.count, keyboardType: .alphabetic)
            registrationStep.answerTextQuestion(text: passwordAlphabeticPart)
            // In order to enter numbers we need to switch to numeric keyboard
            Keyboards.switchKeyboardType() // Switch to numeric
            registrationStep
                .answerIntegerQuestion(number: passwordNumericPart)
                .verifyErrorMessage(exists: false, withId: passwordFormItemId, atIndex: 1, expectedMessage: errorMessage)
        }
        
        test("Verify password confirmation field negative testing") {
            let errorMessage = " Passwords do not match." // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
            registrationStep
                .selectFormItemCell(withID: confirmPasswordFormItemId, atIndex: 2)
                .answerTextQuestion(text: passwordAlphabeticPart, dismissKeyboard: false)
            Keyboards.switchKeyboardType() // Switch to numeric
            registrationStep
                .answerIntegerQuestion(number: 1, dismissKeyboard: true)
                .verifyErrorMessage(exists: true, withId: confirmPasswordFormItemId, atIndex: 2, expectedMessage: errorMessage)
            registrationStep
                .selectFormItemCell(withID: confirmPasswordFormItemId, atIndex: 2)
                .answerTextQuestion(text: passwordAlphabeticPart, dismissKeyboard: false)
            Keyboards.switchKeyboardType() // Switch to numeric
            registrationStep.answerIntegerQuestion(number: passwordNumericPart, dismissKeyboard: true)
                .verifyErrorMessage(exists: false, withId: confirmPasswordFormItemId, atIndex: 2, expectedMessage: errorMessage)
        }
        
        let givenNameFormItemId = "ORKRegistrationFormItemGivenName"
        let familyNameFormItemId = "ORKRegistrationFormItemFamilyName"
        let genderFormItemId = "ORKRegistrationFormItemGender"
        let dobFormItemId = "ORKRegistrationFormItemDOB"
        let phoneNumberFormItemId = "ORKRegistrationFormItemPhoneNumber"
        
        registrationStep
            .selectFormItemCell(withID: givenNameFormItemId)
            .answerTextQuestion(text: "John", dismissKeyboard: true)
        
        registrationStep
            .selectFormItemCell(withID: familyNameFormItemId, atIndex: 1)
            .answerTextQuestion(text: "Appleseed", dismissKeyboard: true)
        
        registrationStep
            .selectFormItemCell(withID: genderFormItemId, atIndex: 2)
            .answerPickerValueChoiceQuestion(value: "Male", dismissPicker: true)
        
        registrationStep
            .selectFormItemCell(withID: dobFormItemId, atIndex: 3)
            .answerDateQuestion(year: "1978", month: "December", day: "25", dismissPicker: true)
        
        test("Verify phone number field negative testing") {
            registrationStep
                .selectFormItemCell(withID: phoneNumberFormItemId, atIndex: 4)
                .answerIntegerQuestion(number: 123, dismissKeyboard: true)
                .verifyErrorMessage(exists: true, withId: phoneNumberFormItemId, atIndex: 4, expectedMessage: " Expected format +1 (555) 555 5555") // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
            registrationStep
                .selectFormItemCell(withID: phoneNumberFormItemId, atIndex: 4)
            Keyboards.deleteValue(characterCount: 3, keyboardType: .alphabetic)
            Keyboards.tapShiftKey() // Switch to symbols
            registrationStep
                .answerTextQuestion(text: "+", dismissKeyboard: false)
            Keyboards.tapShiftKey() // Switch back to numeric
            registrationStep
                .answerTextQuestion(text: "1")
            Keyboards.tapSpace()
            registrationStep.answerTextQuestion(text: "(555)")
            Keyboards.tapSpace()
            registrationStep.answerTextQuestion(text: "555")
            Keyboards.tapSpace()
            registrationStep
                .answerTextQuestion(text: "5555", dismissKeyboard: true)
                .tap(.continueButton)
        }
        
        sleep(5) // Wait for wait step to end
        
        let verificationStep = VerificationStepScreen()
        verificationStep
            .verifyStepView()
            .tapCancelButton()
            .tapDiscardResultsButton()
    }
}
