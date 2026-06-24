//
//  WaveformView.swift
//  DriftDay
//
//  Circular waveform visualizer that reacts to live microphone level.
//

import SwiftUI

struct WaveformView: View {
    /// Normalized 0...1 input level.
    var level: CGFloat
    var isActive: Bool

    private let barCount = 40

    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.15), lineWidth: 2)
                    .frame(width: size, height: size)

                ForEach(0..<barCount, id: \.self) { i in
                    bar(index: i, radius: radius)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentColor.opacity(isActive ? 0.35 : 0.12), .clear],
                            center: .center, startRadius: 0, endRadius: radius * 0.7
                        )
                    )
                    .frame(width: size * 0.55, height: size * 0.55)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { animate() }
    }

    private func bar(index: Int, radius: CGFloat) -> some View {
        let angle = (CGFloat(index) / CGFloat(barCount)) * 2 * .pi
        // Deterministic pseudo-variation so bars aren't uniform.
        let variation = (sin(angle * 3 + phase) + 1) / 2
        let amplitude = isActive ? (0.25 + level * 0.75) : 0.18
        let barLength = radius * 0.28 * (0.4 + variation * amplitude)

        return Capsule()
            .fill(Color.accentColor.opacity(isActive ? 0.9 : 0.4))
            .frame(width: 3, height: max(4, barLength))
            .offset(y: -(radius * 0.72))
            .rotationEffect(.radians(Double(angle)))
            .animation(.easeOut(duration: 0.1), value: level)
    }

    private func animate() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = 2 * .pi
        }
    }
}
