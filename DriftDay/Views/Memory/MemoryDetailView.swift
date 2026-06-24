//
//  MemoryDetailView.swift
//  DriftDay
//
//  Full view of a single completed adventure, with transcript, audio playback,
//  and a system share sheet.
//

import SwiftUI

struct MemoryDetailView: View {
    let item: MemoryItem

    @StateObject private var player = AudioPlayer()
    @State private var showShare = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                HStack(spacing: 10) {
                    Label(item.category.title, systemImage: item.category.iconName)
                        .foregroundStyle(item.category.tint)
                    Text(item.task.durationBadge)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(item.category.tint.opacity(0.15), in: Capsule())
                        .foregroundStyle(item.category.tint)
                }
                .font(.subheadline.weight(.medium))

                if item.audioFileName != nil {
                    PlaybackBar(player: player)
                        .padding(.vertical, 4)
                }

                Divider()

                Text("Impression")
                    .font(.headline)
                Text(transcriptText)
                    .font(.body)
                    .foregroundStyle(hasTranscript ? .primary : .secondary)
            }
            .padding(20)
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showShare = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareText])
        }
        .onAppear {
            if let fileName = item.audioFileName {
                player.load(fileName: fileName)
            }
        }
        .onDisappear { player.stop() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.title2.bold())
            Text(item.date, format: .dateTime.weekday(.wide).month().day().year())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var hasTranscript: Bool {
        !(item.transcript ?? "").isEmpty
    }

    private var transcriptText: String {
        hasTranscript ? (item.transcript ?? "") : "No transcript available"
    }

    private var shareText: String {
        var text = "DriftDay — \(item.title)\n"
        text += DateFormatter.localizedString(from: item.date, dateStyle: .medium, timeStyle: .none)
        if hasTranscript {
            text += "\n\n\(item.transcript ?? "")"
        }
        return text
    }
}
