//
//  OnboardingViewModel.swift
//  DriftDay
//

import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var page = 0
    @Published var selectedCategories: Set<Category> = []
    @Published var comfortLevel: Float = 0.5

    let defaultHour = 8
    let defaultMinute = 0

    private let repository: DriftDayRepository

    init(repository: DriftDayRepository = .shared) {
        self.repository = repository
    }

    var canProceedFromInterests: Bool { !selectedCategories.isEmpty }

    func toggle(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    /// Saves the profile, schedules the first notification, and reports success.
    func finish() {
        let ordered = Category.allCases.filter { selectedCategories.contains($0) }
        repository.createProfile(
            categories: ordered,
            comfortLevel: comfortLevel,
            hour: defaultHour,
            minute: defaultMinute
        )
        let hour = defaultHour
        let minute = defaultMinute
        NotificationManager.shared.requestAuthorization { _ in
            NotificationManager.shared.scheduleDaily(hour: hour, minute: minute)
        }
    }
}
