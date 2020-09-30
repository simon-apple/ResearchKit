//
//  ORKTestApp.swift
//  ORKTest (watchOS) WatchKit Extension
//
//  Created by Joey LaBarck on 8/4/20.
//  Copyright © 2020 ResearchKit. All rights reserved.
//

import SwiftUI
import ResearchKitCore
import ResearchKitUI

@main
struct ORKTestApp: App {
    
    @State var isTaskPresented: Bool = false
    
    let taskManager: TaskManager
    
    init() {

        let leftHanded = ORKTextChoice(text: "Somewhat", detailText: nil, value: NSString(string: "L"), exclusive: true)
        let rightHanded = ORKTextChoice(text: "A lot", detailText: nil, value: NSString(string: "R"), exclusive: true)
        let ambidextrous = ORKTextChoice(text: "Not at all", detailText: nil, value: NSString(string: "A"), exclusive: true)
        let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [leftHanded, rightHanded, ambidextrous])
        let questionStep = ORKQuestionStep(identifier: "questionStep", title: "Are you feeling stressed right now?", question: nil, answer: answerFormat)
        
        let sampleTask = ORKOrderedTask(identifier: "task", steps: [questionStep])
        taskManager = TaskManager(task: sampleTask)
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
                Button(action: {
                    isTaskPresented = true
                }) {
                    Text("Test Task")
                }
                .task(isPresented: $isTaskPresented, taskManager: taskManager)
                .onReceive(taskManager.$finishReason) { finishReason in
                    
                    isTaskPresented = false
                    
                    if let finishReason = finishReason {
                        switch finishReason {
                        case .completed:
                            print("Task Completed: Results: \(String(describing: taskManager.result.results))")
                        default:
                            break
                        }
                    }
                }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
