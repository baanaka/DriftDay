//
//  RootView.swift
//  DriftDay
//
//  Switches between onboarding (full-screen) and the main tab bar.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isOnboarded {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: appState.isOnboarded)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Today", systemImage: "die.face.5") }
            MemoryFeedView()
                .tabItem { Label("Memories", systemImage: "waveform") }
        }
    }
}
