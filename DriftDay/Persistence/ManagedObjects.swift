//
//  ManagedObjects.swift
//  DriftDay
//
//  Manual (Manual/None) Core Data subclasses. Codegen is disabled in the
//  data model, so these are the single source of truth for the entities.
//

import Foundation
import CoreData

// MARK: - UserProfile

@objc(UserProfile)
public final class UserProfile: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var id: UUID
    @NSManaged public var interestCategories: String
    @NSManaged public var comfortLevel: Float
    @NSManaged public var notificationHour: Int16
    @NSManaged public var notificationMinute: Int16
    @NSManaged public var onboardingComplete: Bool
    @NSManaged public var createdAt: Date
}

extension UserProfile {
    /// Interests as a typed array of `Category`.
    var categories: [Category] {
        get {
            interestCategories
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .compactMap { Category(rawValue: $0) }
        }
        set {
            interestCategories = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }
}

// MARK: - DailyTask

@objc(DailyTask)
public final class DailyTask: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyTask> {
        NSFetchRequest<DailyTask>(entityName: "DailyTask")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var categoryName: String
    @NSManaged public var taskDescription: String
    @NSManaged public var estimatedMinutes: Int16
    @NSManaged public var visualThemeIndex: Int16
    @NSManaged public var generationSeed: Int64
    @NSManaged public var isRevealed: Bool
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isSkipped: Bool
    @NSManaged public var revealedAt: Date?
    @NSManaged public var completedAt: Date?
}

extension DailyTask {
    var category: Category { Category(rawValue: categoryName) ?? .routes }
    var durationBadge: String { "~\(estimatedMinutes) min" }
}

// MARK: - VoiceImpression

@objc(VoiceImpression)
public final class VoiceImpression: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoiceImpression> {
        NSFetchRequest<VoiceImpression>(entityName: "VoiceImpression")
    }

    @NSManaged public var id: UUID
    @NSManaged public var taskID: UUID
    @NSManaged public var audioFileName: String
    @NSManaged public var transcript: String?
    @NSManaged public var recordedAt: Date
    @NSManaged public var durationSeconds: Double
}

// MARK: - StreakRecord

@objc(StreakRecord)
public final class StreakRecord: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StreakRecord> {
        NSFetchRequest<StreakRecord>(entityName: "StreakRecord")
    }

    @NSManaged public var id: UUID
    @NSManaged public var currentStreak: Int32
    @NSManaged public var longestStreak: Int32
    @NSManaged public var totalCompleted: Int32
    @NSManaged public var lastCompletedDate: Date?
}
