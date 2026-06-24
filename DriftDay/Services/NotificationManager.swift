//
//  NotificationManager.swift
//  DriftDay
//
//  Local-only daily "dice roll" notification. No remote push, no service
//  extension — everything is scheduled from the main app target.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    static let dailyIdentifier = "driftday.daily.prompt"

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion?(granted) }
        }
    }

    /// Cancels any existing daily prompt and schedules a new repeating one.
    func scheduleDaily(hour: Int, minute: Int) {
        cancelDaily()

        let content = UNMutableNotificationContent()
        content.title = "DriftDay"
        content.body = "Your micro-adventure is ready. Roll the dice and reveal today's task."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelDaily() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyIdentifier])
    }

    /// Used by tests / verification (criterion 11) to inspect pending requests.
    func pendingDailyRequest(completion: @escaping (UNNotificationRequest?) -> Void) {
        center.getPendingNotificationRequests { requests in
            let match = requests.first { $0.identifier == Self.dailyIdentifier }
            DispatchQueue.main.async { completion(match) }
        }
    }
}
