//
//  PlaybackBar.swift
//  DriftDay
//
//  Reusable audio playback control with play/pause, scrub slider, and
//  elapsed / total timestamps.
//

import SwiftUI

struct PlaybackBar: View {
    @ObservedObject var player: AudioPlayer

    @State private var isScrubbing = false
    @State private var scrubValue: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 14) {
                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                }

                VStack(spacing: 2) {
                    Slider(
                        value: Binding(
                            get: { isScrubbing ? scrubValue : player.currentTime },
                            set: { scrubValue = $0 }
                        ),
                        in: 0...max(player.duration, 0.01),
                        onEditingChanged: { editing in
                            isScrubbing = editing
                            if !editing { player.seek(to: scrubValue) }
                        }
                    )
                    HStack {
                        Text(timeString(player.currentTime))
                        Spacer()
                        Text(timeString(player.duration))
                    }
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let total = Int(time.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
