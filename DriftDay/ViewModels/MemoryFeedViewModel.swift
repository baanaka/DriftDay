//
//  MemoryFeedViewModel.swift
//  DriftDay
//

import SwiftUI
import Combine

/// A completed task plus its (optional) impression, ready for display.
struct MemoryItem: Identifiable {
    let id: UUID
    let task: DailyTask
    let impression: VoiceImpression?

    var title: String { task.title }
    var date: Date { task.completedAt ?? task.date }
    var category: Category { task.category }
    var transcript: String? { impression?.transcript }
    var audioFileName: String? { impression?.audioFileName }

    var transcriptExcerpt: String {
        guard let transcript, !transcript.isEmpty else { return "No transcript" }
        if transcript.count <= 80 { return transcript }
        return String(transcript.prefix(80)) + "…"
    }
}

struct MemorySection: Identifiable {
    let id: String          // "Month YYYY"
    let title: String
    let items: [MemoryItem]
}

@MainActor
final class MemoryFeedViewModel: ObservableObject {
    @Published private(set) var sections: [MemorySection] = []
    @Published var searchText = "" { didSet { rebuild() } }

    private var allItems: [MemoryItem] = []
    private let repository: DriftDayRepository

    private lazy var monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    init(repository: DriftDayRepository = .shared) {
        self.repository = repository
    }

    func load() {
        allItems = repository.completedTasks().map { task in
            MemoryItem(id: task.id, task: task, impression: repository.impression(for: task.id))
        }
        rebuild()
    }

    private func rebuild() {
        let filtered: [MemoryItem]
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            filtered = allItems
        } else {
            filtered = allItems.filter { item in
                item.title.lowercased().contains(query) ||
                (item.transcript?.lowercased().contains(query) ?? false)
            }
        }

        // Group by month, preserving newest-first order; drop empty months.
        let calendar = Calendar.current
        var order: [String] = []
        var buckets: [String: [MemoryItem]] = [:]
        for item in filtered {
            let comps = calendar.dateComponents([.year, .month], from: item.date)
            let key = "\(comps.year ?? 0)-\(comps.month ?? 0)"
            if buckets[key] == nil { order.append(key); buckets[key] = [] }
            buckets[key]?.append(item)
        }

        sections = order.compactMap { key in
            guard let items = buckets[key], let first = items.first else { return nil }
            return MemorySection(
                id: key,
                title: monthFormatter.string(from: first.date),
                items: items
            )
        }
    }
}
