//
//  AppState.swift
//  DriftDay
//
//  Drives the root-level switch between onboarding and the main tab bar, and
//  carries shared dependencies down through the environment.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isOnboarded: Bool

    let repository: DriftDayRepository

    init(repository: DriftDayRepository = .shared) {
        self.repository = repository
        self.isOnboarded = repository.currentProfile()?.onboardingComplete ?? false
    }

    func completeOnboarding() {
        isOnboarded = true
    }

    /// Called by "Clear All Data" — wipes everything and returns to onboarding.
    func resetToOnboarding() {
        repository.clearAllData()
        isOnboarded = false
    }
}
