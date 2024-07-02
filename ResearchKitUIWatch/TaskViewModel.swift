//
//  TaskViewModel.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 7/1/24.
//

import SwiftUI

public class TaskViewModel: ObservableObject {
    @Published var stepCount: [Int] = []
    @Published var steps: [[FormRow]] = []

    public init(
        stepCount: [Int],
        steps: [[FormRow]]
    ) {
        self.stepCount = stepCount
        self.steps = steps
    }
}
