//
//  MemoryFeedView.swift
//  DriftDay
//
//  Second tab — a searchable, month-grouped list of completed adventures.
//

import SwiftUI

struct MemoryFeedView: View {
    @StateObject private var viewModel = MemoryFeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sections.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.sections) { section in
                            Section(section.title) {
                                ForEach(section.items) { item in
                                    NavigationLink(value: item.id) {
                                        MemoryRow(item: item)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Memories")
            .navigationDestination(for: UUID.self) { id in
                if let item = viewModel.sections.flatMap(\.items).first(where: { $0.id == id }) {
                    MemoryDetailView(item: item)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search titles and transcripts")
            .onAppear { viewModel.load() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.and.mic")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No memories yet")
                .font(.headline)
            Text("Complete a daily drift to start your audio diary.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

private struct MemoryRow: View {
    let item: MemoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.iconName)
                .font(.title3)
                .foregroundStyle(item.category.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(item.date, format: .dateTime.month().day().year())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(item.transcriptExcerpt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if item.audioFileName != nil {
                Image(systemName: "play.circle")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 4)
    }
}
