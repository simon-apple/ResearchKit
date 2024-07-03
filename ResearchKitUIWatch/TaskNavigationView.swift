//
//  TaskNavigationView.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 7/1/24.
//
import SwiftUI

public struct TaskNavigationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    var onTaskCompletion: (() -> Void)?

    public init(
        viewModel: TaskViewModel,
        onTaskCompletion: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onTaskCompletion = onTaskCompletion
    }

    public var body: some View {
        NavigationStack(path: $viewModel.stepCount) {
            TaskStepContentView(
                viewModel: viewModel,
                path: 0,
                onDismissButtonTapped: {
                    dismiss()
                },
                onDoneButtonTapped: {
                    onTaskCompletion?()
                }
            )
            .navigationDestination(for: Int.self) { path in
                TaskStepContentView(
                    viewModel: viewModel,
                    path: path,
                    onDismissButtonTapped: {
                        dismiss()
                    },
                    onDoneButtonTapped: {
                        onTaskCompletion?()
                    }
                )
            }
        }
    }
}

public struct TaskStepContentView: View {
    @ObservedObject
    var viewModel: TaskViewModel

    let path: Int
    var onDismissButtonTapped: (() -> Void)?
    var onDoneButtonTapped: (() -> Void)?

    var isLastStep: Bool {
        path == (viewModel.steps.count - 1)
    }

    public var body: some View {
        StickyScrollView {
            VStack {
                ForEach($viewModel.steps[path]) { $row in
                    FormRowContent(detail: nil, formRow: $row)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismissButtonTapped?()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        } footerContent: {
            Button {
                if isLastStep {
                    onDoneButtonTapped?()
                } else {
                    viewModel.stepCount.append(path + 1)
                }
            } label: {
                Text(isLastStep ? "Done" : "Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: maxWidthForDoneButton)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationTitle("\(path + 1) of \(viewModel.steps.count)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var maxWidthForDoneButton: CGFloat {
#if os(iOS)
        .infinity
#elseif os(visionOS)
        300
#endif
    }
}
