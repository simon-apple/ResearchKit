//
//  ORKTestApp.swift
//  ORKTest (watchOS) WatchKit Extension
//
//  Created by Joey LaBarck on 8/4/20.
//  Copyright © 2020 ResearchKit. All rights reserved.
//

import SwiftUI
import ResearchKitCore

@main
struct ORKTestApp: App {
    
    let sampleTask: ORKOrderedTask
    
    init() {
        
        let instructionStep = ORKInstructionStep(identifier: "instructionStep")
        instructionStep.title = "Welcome To Watch OS!"
        instructionStep.detailText = "You will be asked a question."
        
        let leftHanded = ORKTextChoice(text: "Left Hand", detailText: nil, value: NSString(string: "L"), exclusive: true)
        let rightHanded = ORKTextChoice(text: "Right Hand", detailText: nil, value: NSString(string: "R"), exclusive: true)
        let ambidextrous = ORKTextChoice(text: "Both", detailText: nil, value: NSString(string: "A"), exclusive: true)
        let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [leftHanded, rightHanded, ambidextrous])
        let questionStep = ORKQuestionStep(identifier: "questionStep", title: "Handedness", question: "Which is your dominant hand?", answer: answerFormat)
        
        let completionStep = ORKCompletionStep(identifier: "completionStep")
        completionStep.title = "Thank You"
        completionStep.detailText = "You have completed this task."
        
        sampleTask = ORKOrderedTask(identifier: "task", steps: [instructionStep, questionStep, completionStep])
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
