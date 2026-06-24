//
//  DriftDayApp.swift
//  DriftDay
//
//  App entry point. Wires up Core Data, app state, and the notification
//  delegate so tapping the daily prompt opens the Home screen.
//

import SwiftUI
import UserNotifications

@main
struct DriftDayApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}

/// Handles foreground presentation of the local notification so the prompt is
/// visible even while the app is open. Tapping it lands on the default (Today)
/// tab — no deep links required.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Tapping the prompt simply opens the app on the Today tab.
        completionHandler()
    }
}
