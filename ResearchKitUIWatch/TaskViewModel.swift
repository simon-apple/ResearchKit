//
//  TaskViewModel.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 7/1/24.
//

import SwiftUI

public class TaskViewModel: ObservableObject {
    @Published var stepCount: [Int] = []
    var steps: [[FormRow]] = []

    public init(
        stepCount: [Int],
        steps: [[FormRow]]
    ) {
        self.stepCount = stepCount
        self.steps = steps
    }

    // Add an array of pages of step count

    // Add func for formStepForPage() -> [FormRow]
}
