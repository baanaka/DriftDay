//
//  ProfileViewModel.swift
//  DriftDay
//

import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var selectedCategories: Set<Category> = []
    @Published var comfortLevel: Float = 0.5
    @Published var notificationTime = Date()

    @Published private(set) var currentStreak = 0
    @Published private(set) var longestStreak = 0
    @Published private(set) var totalCompleted = 0

    private let repository: DriftDayRepository

    init(repository: DriftDayRepository = .shared) {
        self.repository = repository
    }

    func load() {
        guard let profile = repository.currentProfile() else { return }
        selectedCategories = Set(profile.categories)
        comfortLevel = profile.comfortLevel

        var comps = DateComponents()
        comps.hour = Int(profile.notificationHour)
        comps.minute = Int(profile.notificationMinute)
        notificationTime = Calendar.current.date(from: comps) ?? Date()

        let record = repository.streakRecord()
        currentStreak = Int(record.currentStreak)
        longestStreak = Int(record.longestStreak)
        totalCompleted = Int(record.totalCompleted)
    }

    func toggle(_ category: Category) {
        if selectedCategories.contains(category) {
            // Keep at least one interest active.
            guard selectedCategories.count > 1 else { return }
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        saveInterests()
    }

    private func saveInterests() {
        let ordered = Category.allCases.filter { selectedCategories.contains($0) }
        repository.updateProfileInterests(ordered)
    }

    func saveComfort() {
        repository.updateComfortLevel(comfortLevel)
    }

    func saveNotificationTime() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        repository.updateNotificationTime(hour: comps.hour ?? 8, minute: comps.minute ?? 0)
    }

    func resetStreak() {
        repository.resetStreak()
        currentStreak = 0
    }
}
