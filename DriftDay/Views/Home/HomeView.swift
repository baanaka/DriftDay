//
//  HomeView.swift
//  DriftDay
//
//  Primary "Today's Task" screen.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let task = viewModel.task {
                        SealedCardView(
                            task: task,
                            style: viewModel.dayStyle,
                            streak: viewModel.currentStreak,
                            isFlipped: viewModel.isFlipped
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        actionArea(task: task)
                    } else {
                        ProgressView().padding(.top, 80)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showProfile = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .onAppear { viewModel.load() }
            .confirmationDialog(
                "Skip resets your streak. Continue?",
                isPresented: $viewModel.showSkipConfirmation,
                titleVisibility: .visible
            ) {
                Button("Confirm Skip", role: .destructive) { viewModel.confirmSkip() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $viewModel.showVoiceSheet) {
                if let task = viewModel.task {
                    VoiceImpressionView(task: task) {
                        viewModel.showVoiceSheet = false
                        viewModel.load()
                    }
                    .interactiveDismissDisabled(true)
                }
            }
        }
    }

    @ViewBuilder
    private func actionArea(task: DailyTask) -> some View {
        VStack(spacing: 14) {
            if !viewModel.isFlipped {
                Button("Reveal Today's Task") { viewModel.reveal() }
                    .buttonStyle(PrimaryButtonStyle())
            } else if viewModel.isDone {
                Label("Completed for today", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(.vertical, 8)
            } else if viewModel.isSkipped {
                Label("Skipped today", systemImage: "xmark.circle")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                Button {
                    viewModel.showVoiceSheet = true
                } label: {
                    Label("Mark as Done & Record Impression", systemImage: "mic.fill")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Skip Today") {
                    viewModel.showSkipConfirmation = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 32)
    }
}
