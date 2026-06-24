//
//  DriftDayRepository.swift
//  DriftDay
//
//  Central business logic over Core Data: profile, daily task get-or-create,
//  and streak reconciliation. View models talk to this rather than touching
//  the context directly, keeping the streak rules in one place.
//

import Foundation
import CoreData

@MainActor
final class DriftDayRepository {
    static let shared = DriftDayRepository(persistence: .shared)

    private let persistence: PersistenceController
    private var context: NSManagedObjectContext { persistence.viewContext }
    private let calendar: Calendar

    init(persistence: PersistenceController, calendar: Calendar = .current) {
        self.persistence = persistence
        self.calendar = calendar
    }

    // MARK: - Profile

    func currentProfile() -> UserProfile? {
        let request = UserProfile.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    @discardableResult
    func createProfile(categories: [Category], comfortLevel: Float,
                       hour: Int, minute: Int) -> UserProfile {
        // Only one profile exists; reuse if present, otherwise mint a fresh one.
        let profile: UserProfile
        if let existing = currentProfile() {
            profile = existing
        } else {
            profile = UserProfile(context: context)
            profile.id = UUID()
        }
        profile.categories = categories
        profile.comfortLevel = comfortLevel
        profile.notificationHour = Int16(hour)
        profile.notificationMinute = Int16(minute)
        profile.onboardingComplete = true
        profile.createdAt = Date()
        ensureStreakRecord()
        persistence.save()
        return profile
    }

    func updateProfileInterests(_ categories: [Category]) {
        guard let profile = currentProfile() else { return }
        profile.categories = categories
        persistence.save()
    }

    func updateComfortLevel(_ value: Float) {
        guard let profile = currentProfile() else { return }
        profile.comfortLevel = value
        persistence.save()
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        guard let profile = currentProfile() else { return }
        profile.notificationHour = Int16(hour)
        profile.notificationMinute = Int16(minute)
        persistence.save()
        NotificationManager.shared.scheduleDaily(hour: hour, minute: minute)
    }

    // MARK: - Streak record

    @discardableResult
    func streakRecord() -> StreakRecord {
        if let existing = try? context.fetch(StreakRecord.fetchRequest()).first {
            return existing
        }
        return ensureStreakRecord()
    }

    @discardableResult
    private func ensureStreakRecord() -> StreakRecord {
        if let existing = try? context.fetch(StreakRecord.fetchRequest()).first {
            return existing
        }
        let record = StreakRecord(context: context)
        record.id = UUID()
        record.currentStreak = 0
        record.longestStreak = 0
        record.totalCompleted = 0
        record.lastCompletedDate = nil
        return record
    }

    // MARK: - Daily task

    /// Returns today's task, generating and persisting it exactly once per day.
    func todaysTask() -> DailyTask? {
        guard let profile = currentProfile() else { return nil }
        reconcileMissedDays()

        let startOfDay = calendar.startOfDay(for: Date())
        if let existing = task(on: startOfDay) {
            return existing
        }

        let streak = Int(streakRecord().currentStreak)
        let hash = TaskGenerator.profileHash(
            profileID: profile.id,
            interestCategories: profile.interestCategories
        )
        let generated = TaskGenerator.generate(
            for: startOfDay,
            comfortLevel: profile.comfortLevel,
            categories: profile.categories,
            profileHash: hash,
            currentStreak: streak,
            calendar: calendar
        )

        let task = DailyTask(context: context)
        task.id = UUID()
        task.date = startOfDay
        task.title = generated.title
        task.categoryName = generated.categoryName
        task.taskDescription = generated.description
        task.estimatedMinutes = Int16(generated.estimatedMinutes)
        task.visualThemeIndex = Int16(generated.visualThemeIndex)
        task.generationSeed = generated.generationSeed
        task.isRevealed = false
        task.isCompleted = false
        task.isSkipped = false
        persistence.save()
        return task
    }

    func task(on day: Date) -> DailyTask? {
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
        let request = DailyTask.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func markRevealed(_ task: DailyTask) {
        guard !task.isRevealed else { return }
        task.isRevealed = true
        task.revealedAt = Date()
        persistence.save()
    }

    // MARK: - Completion & skip

    /// Marks today complete and advances the streak. Idempotent per day.
    func completeToday(_ task: DailyTask) {
        guard !task.isCompleted else { return }
        task.isCompleted = true
        task.isSkipped = false
        task.completedAt = Date()

        let record = streakRecord()
        record.currentStreak += 1
        record.totalCompleted += 1
        record.longestStreak = max(record.longestStreak, record.currentStreak)
        record.lastCompletedDate = calendar.startOfDay(for: Date())
        persistence.save()
    }

    func skipToday(_ task: DailyTask) {
        task.isSkipped = true
        task.isCompleted = false
        let record = streakRecord()
        record.currentStreak = 0
        persistence.save()
    }

    /// If at least one full calendar day elapsed without a completion, the
    /// streak is broken (criterion 9).
    func reconcileMissedDays() {
        let record = streakRecord()
        guard record.currentStreak > 0, let last = record.lastCompletedDate else { return }
        let lastDay = calendar.startOfDay(for: last)
        let today = calendar.startOfDay(for: Date())
        let gap = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        // gap 0 = completed today, gap 1 = completed yesterday (still alive).
        if gap > 1 {
            record.currentStreak = 0
            persistence.save()
        }
    }

    // MARK: - Voice impressions

    @discardableResult
    func saveImpression(taskID: UUID, audioFileName: String, transcript: String?,
                        duration: Double) -> VoiceImpression {
        let impression = VoiceImpression(context: context)
        impression.id = UUID()
        impression.taskID = taskID
        impression.audioFileName = audioFileName
        impression.transcript = transcript
        impression.recordedAt = Date()
        impression.durationSeconds = duration
        persistence.save()
        return impression
    }

    func impression(for taskID: UUID) -> VoiceImpression? {
        let request = VoiceImpression.fetchRequest()
        request.predicate = NSPredicate(format: "taskID == %@", taskID as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    // MARK: - Memory feed

    func completedTasks() -> [DailyTask] {
        let request = DailyTask.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Reset & wipe

    func resetStreak() {
        let record = streakRecord()
        record.currentStreak = 0
        persistence.save()
    }

    func clearAllData() {
        AudioFileStore.deleteAllAudioFiles()
        persistence.wipeAllData()
        NotificationManager.shared.cancelDaily()
    }
}
