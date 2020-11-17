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
    
    @State
    private var isTaskPresented: Bool = false
    
    @State
    private var taskManager: TaskManager = ORKTestApp.newTaskManager()
    
    static func newTaskManager() -> TaskManager {
        let leftHanded = ORKTextChoice(text: "Somewhat", detailText: nil, value: NSString(string: "L"), exclusive: true)
        let rightHanded = ORKTextChoice(text: "A lot", detailText: nil, value: NSString(string: "R"), exclusive: true)
        let ambidextrous = ORKTextChoice(text: "Not at all", detailText: nil, value: NSString(string: "A"), exclusive: true)
        let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [leftHanded, rightHanded, ambidextrous])
        let questionStep = ORKQuestionStep(identifier: "questionStep", title: "Are you feeling stressed right now?", question: nil, answer: answerFormat)
        let questionStep2 = ORKQuestionStep(identifier: "questionStep2", title: "Are you feeling calm right now?", question: nil, answer: answerFormat)
        let questionStep3 = ORKQuestionStep(identifier: "questionStep3", title: "Are you feeling tired right now?", question: nil, answer: answerFormat)
        
        let sampleTask = ORKOrderedTask(identifier: "task", steps: [questionStep, questionStep2, questionStep3])
        return TaskManager(task: sampleTask)
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
                        
                        taskManager = ORKTestApp.newTaskManager()
                        
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
