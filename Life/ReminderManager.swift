import Foundation
import UserNotifications

class ReminderManager {
    static let shared = ReminderManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            print("[DEBUG] Notification permission granted:", granted)
        }
    }

    func scheduleDailyReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let center = UNUserNotificationCenter.current()

        for hour in stride(from: 10, through: 22, by: 2) {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "💧 Time to drink water"
            content.body = "Stay hydrated!"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(identifier: "hydration_\(hour)", content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("[DEBUG] Failed to schedule \(hour):", error)
                } else {
                    print("[DEBUG] Scheduled hydration reminder at \(hour):00")
                }
            }
        }
    }
}
