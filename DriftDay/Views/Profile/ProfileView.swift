//
//  ProfileView.swift
//  DriftDay
//
//  Editable interests, comfort zone, streak stats, notification time, and the
//  destructive reset / clear-all flows.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showResetStreakAlert = false
    @State private var showClearWarning = false
    @State private var showClearFinalConfirm = false

    var body: some View {
        Form {
            interestsSection
            comfortSection
            statsSection
            notificationSection
            dangerSection
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
        // Reset streak — single confirmation.
        .alert("Reset Streak?", isPresented: $showResetStreakAlert) {
            Button("Reset", role: .destructive) { viewModel.resetStreak() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current streak will return to zero. This can't be undone.")
        }
        // Clear all data — step 1 warning.
        .alert("Clear All Data?", isPresented: $showClearWarning) {
            Button("Continue", role: .destructive) { showClearFinalConfirm = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes your profile, every memory, and all recordings. You'll start over at onboarding.")
        }
        // Clear all data — step 2 final confirm.
        .alert("Are you absolutely sure?", isPresented: $showClearFinalConfirm) {
            Button("Delete Everything", role: .destructive) {
                appState.resetToOnboarding()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("There is no way to recover this data.")
        }
    }

    private var interestsSection: some View {
        Section("Interests") {
            CategoryChipGrid(
                selected: viewModel.selectedCategories,
                onToggle: { viewModel.toggle($0) }
            )
            .padding(.vertical, 4)
            Text("Changes take effect with tomorrow's task.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var comfortSection: some View {
        Section("Comfort Zone") {
            HStack {
                Text("Familiar")
                Slider(value: $viewModel.comfortLevel, in: 0...1) { editing in
                    if !editing { viewModel.saveComfort() }
                }
                Text("Adventurous")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var statsSection: some View {
        Section("Streak Stats") {
            statRow(label: "Current streak", value: "\(viewModel.currentStreak) days", symbol: "flame.fill")
            statRow(label: "Longest streak", value: "\(viewModel.longestStreak) days", symbol: "trophy.fill")
            statRow(label: "Total completed", value: "\(viewModel.totalCompleted)", symbol: "checkmark.seal.fill")
        }
    }

    private var notificationSection: some View {
        Section("Notification Time") {
            DatePicker(
                "Daily reminder",
                selection: $viewModel.notificationTime,
                displayedComponents: .hourAndMinute
            )
            .onChange(of: viewModel.notificationTime) { _, _ in
                viewModel.saveNotificationTime()
            }
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetStreakAlert = true
            } label: {
                Label("Reset Streak", systemImage: "arrow.counterclockwise")
            }
            Button(role: .destructive) {
                showClearWarning = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
            }
        } footer: {
            Text("Clearing data removes everything and returns you to onboarding.")
        }
    }

    private func statRow(label: String, value: String, symbol: String) -> some View {
        HStack {
            Label(label, systemImage: symbol)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
