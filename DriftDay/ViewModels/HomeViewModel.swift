//
//  HomeViewModel.swift
//  DriftDay
//

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var task: DailyTask?
    @Published private(set) var currentStreak: Int = 0
    @Published var isFlipped = false
    @Published var showSkipConfirmation = false
    @Published var showVoiceSheet = false

    private let repository: DriftDayRepository

    init(repository: DriftDayRepository = .shared) {
        self.repository = repository
    }

    var dayStyle: DayStyle {
        DayStyle.style(at: Int(task?.visualThemeIndex ?? 0))
    }

    var canRecord: Bool {
        guard let task else { return false }
        return task.isRevealed && !task.isCompleted && !task.isSkipped
    }

    var isDone: Bool { task?.isCompleted ?? false }
    var isSkipped: Bool { task?.isSkipped ?? false }

    func load() {
        let task = repository.todaysTask()
        self.task = task
        self.currentStreak = Int(repository.streakRecord().currentStreak)
        // Restore flip state without re-animating (criterion 5).
        self.isFlipped = task?.isRevealed ?? false
    }

    func reveal() {
        guard let task, !task.isRevealed else { return }
        repository.markRevealed(task)
        withAnimation(.easeInOut(duration: 0.6)) {
            isFlipped = true
        }
        objectWillChange.send()
    }

    func confirmSkip() {
        guard let task else { return }
        repository.skipToday(task)
        currentStreak = Int(repository.streakRecord().currentStreak)
        objectWillChange.send()
    }

    /// Called when the voice sheet reports the day as complete.
    func refreshAfterCompletion() {
        currentStreak = Int(repository.streakRecord().currentStreak)
        objectWillChange.send()
    }
}
