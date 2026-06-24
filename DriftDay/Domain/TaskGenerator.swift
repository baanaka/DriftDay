//
//  TaskGenerator.swift
//  DriftDay
//
//  Deterministic, backend-free daily task generation. The same (date, profile,
//  streak) always yields the same task, so relaunching never regenerates it.
//

import Foundation

struct GeneratedTask {
    let title: String
    let categoryName: String
    let description: String
    let estimatedMinutes: Int
    let visualThemeIndex: Int
    let generationSeed: Int64
    let effectiveBoldness: Double
}

enum TaskGenerator {

    /// How much boldness is added per completed week of streak.
    static let boldnessStepPerWeek = 0.12

    /// Stable hash of the user's profile, used as part of the daily seed.
    static func profileHash(profileID: UUID, interestCategories: String) -> UInt64 {
        UInt64.stableHash(profileID.uuidString + "|" + interestCategories)
    }

    /// Boldness offset earned by streak. After 7 consecutive days the offset
    /// jumps by one step, demonstrably raising the boldness floor (criterion 10).
    static func boldnessOffset(forStreak streak: Int) -> Double {
        let weeks = max(0, streak) / 7
        return Double(weeks) * boldnessStepPerWeek
    }

    static func generate(
        for date: Date,
        comfortLevel: Float,
        categories: [Category],
        profileHash: UInt64,
        currentStreak: Int,
        calendar: Calendar = .current
    ) -> GeneratedTask {

        let comps = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let year = UInt64(comps.year ?? 2000)
        let month = UInt64(comps.month ?? 1)
        let day = UInt64(comps.day ?? 1)
        let weekdayIndex = (comps.weekday ?? 1) - 1   // 0 ... 6

        // Daily seed mixes the calendar day with the stable profile hash.
        let dayNumber = year &* 10000 &+ month &* 100 &+ day
        let seed = dayNumber &* 0x100000001b3 ^ profileHash
        var rng = SeededGenerator(seed: seed)

        // Effective boldness target for today.
        let offset = boldnessOffset(forStreak: currentStreak)
        let effective = min(1.0, max(0.0, Double(comfortLevel) + offset))

        // Candidate pool, ranked by closeness to the target boldness.
        let pool = TaskCatalog.templates(for: categories)
        let ranked = pool.sorted {
            abs($0.boldness - effective) < abs($1.boldness - effective)
        }
        let candidateCount = min(6, ranked.count)
        let candidates = Array(ranked.prefix(candidateCount))
        let chosen = candidates.randomElement(using: &rng) ?? ranked[0]

        // Visual theme: day-of-week XOR seed-derived value, into 0...4.
        let seedDerived = Int(truncatingIfNeeded: seed >> 8)
        let themeIndex = abs((weekdayIndex ^ seedDerived)) % 5

        return GeneratedTask(
            title: String(chosen.title.prefix(60)),
            categoryName: chosen.category.rawValue,
            description: chosen.description,
            estimatedMinutes: chosen.estimatedMinutes,
            visualThemeIndex: themeIndex,
            generationSeed: Int64(bitPattern: seed),
            effectiveBoldness: effective
        )
    }
}
