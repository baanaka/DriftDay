//
//  SealedCardView.swift
//  DriftDay
//
//  The card that flips from a sealed "day style" face to the revealed task.
//

import SwiftUI

struct SealedCardView: View {
    let task: DailyTask
    let style: DayStyle
    let streak: Int
    let isFlipped: Bool

    var body: some View {
        ZStack {
            // Sealed face (front)
            cardBackground
                .overlay(sealedContent)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // Revealed face (back)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(revealedContent)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(style.gradient.first ?? .accentColor, lineWidth: 2)
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: 360)
        .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
        .overlay(alignment: .topTrailing) { streakBadge.padding(16) }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(LinearGradient(colors: style.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var sealedContent: some View {
        VStack(spacing: 18) {
            Image(systemName: style.sealSymbol)
                .font(.system(size: 64, weight: .bold))
            Text("Today's drift is sealed")
                .font(.title3.weight(.semibold))
            Text(style.name)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.25), in: Capsule())
        }
        .foregroundStyle(.white)
    }

    private var revealedContent: some View {
        VStack(spacing: 16) {
            Image(systemName: task.category.iconName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(task.category.tint)

            Text(task.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text(task.taskDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(task.durationBadge)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(task.category.tint.opacity(0.18), in: Capsule())
                .foregroundStyle(task.category.tint)
        }
        .padding(.vertical, 24)
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(streak)")
                .font(.subheadline.weight(.bold))
        }
        .foregroundStyle(streak > 0 ? .orange : .secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
