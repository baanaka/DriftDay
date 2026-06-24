//
//  OnboardingView.swift
//  DriftDay
//
//  Three swipeable pages shown only on first launch.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack {
            TabView(selection: $viewModel.page) {
                welcomePage.tag(0)
                interestsPage.tag(1)
                comfortPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: viewModel.page)
        }
        .background(Color(.systemBackground))
    }

    // MARK: Page 1 — Welcome

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()
            FlippingHeroCard()
            VStack(spacing: 10) {
                Text("DriftDay")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text("One unexpected micro-adventure, every single morning.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Button("Next") { withAnimation { viewModel.page = 1 } }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }

    // MARK: Page 2 — Interests

    private var interestsPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)
            VStack(spacing: 8) {
                Text("What pulls you in?")
                    .font(.title.bold())
                Text("Pick at least one. We'll bias your adventures toward these.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            CategoryChipGrid(
                selected: viewModel.selectedCategories,
                onToggle: { viewModel.toggle($0) }
            )
            .padding(.horizontal, 20)

            Spacer()
            Button("Next") { withAnimation { viewModel.page = 2 } }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.canProceedFromInterests)
                .opacity(viewModel.canProceedFromInterests ? 1 : 0.5)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }

    // MARK: Page 3 — Comfort zone

    private var comfortPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)
            VStack(spacing: 8) {
                Text("Set your baseline")
                    .font(.title.bold())
                Text("How bold should your daily drift be?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 16) {
                HStack {
                    Text("Familiar")
                    Spacer()
                    Text("Adventurous")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

                Slider(value: $viewModel.comfortLevel, in: 0...1)
                    .tint(.accentColor)

                Text(boldnessLabel)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button("Get Started") {
                viewModel.finish()
                appState.completeOnboarding()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private var boldnessLabel: String {
        switch viewModel.comfortLevel {
        case ..<0.2: return "Gentle nudges"
        case ..<0.45: return "Comfortable steps"
        case ..<0.7: return "A little daring"
        case ..<0.9: return "Boldly curious"
        default: return "Fully untethered"
        }
    }
}

// MARK: - Hero card flip animation

private struct FlippingHeroCard: View {
    @State private var flipped = false

    var body: some View {
        ZStack {
            cardFace(symbol: "questionmark", colors: DayStyle.all[2].gradient)
                .opacity(flipped ? 0 : 1)
                .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            cardFace(symbol: "sparkles", colors: DayStyle.all[0].gradient)
                .opacity(flipped ? 1 : 0)
                .rotation3DEffect(.degrees(flipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 160, height: 200)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).delay(0.4).repeatForever(autoreverses: true)) {
                flipped = true
            }
        }
    }

    private func cardFace(symbol: String, colors: [Color]) -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                Image(systemName: symbol)
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)
            )
            .shadow(radius: 12, y: 6)
    }
}

// MARK: - Shared button style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
