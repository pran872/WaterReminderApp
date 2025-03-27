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

    func scheduleHydrationReminders(from date: Date) {
        print("Date: ", date)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let earliestReminderHour = HydrationConstants.reminderStartHour - HydrationConstants.baseReminderDelay // 8AM
        
        if hour >= (HydrationConstants.reminderEndHour - HydrationConstants.baseReminderDelay) { // if hour >= 21
            print("[DEBUG] It's after 9PM. No reminders will be scheduled tonight.")
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            let adjustedStart = calendar.date(bySettingHour: earliestReminderHour, minute: 0, second: 0, of: tomorrow) ?? tomorrow
            scheduleHydrationReminders(from: adjustedStart)
            return
        }
        if hour < earliestReminderHour {
            print("[DEBUG] It's before 8AM. No reminders will be scheduled until 10AM.")
            let adjustedStart = Calendar.current.date(
                bySettingHour: earliestReminderHour, minute: 0, second: 0, of: date
            ) ?? date
            scheduleHydrationReminders(from: adjustedStart)
            return
        }
        
        let titles = [
            "💧 Time to drink water",
            "💧 Gentle Reminder",
            "💧 Still waiting...",
            "💧 It's really time now",
            "💧 Final hydration alert"
        ]
        
        for (index, offset) in HydrationConstants.intervals.enumerated() {
            if let reminderDate = calendar.date(byAdding: .minute, value: offset, to: date) {
                let reminderHour = calendar.component(.hour, from: reminderDate)
                if reminderHour >= HydrationConstants.reminderStartHour && reminderHour < HydrationConstants.reminderEndHour {
                    let content = UNMutableNotificationContent()
                    content.title = titles[index]
                    content.body = "You haven't logged water yet. Stay hydrated!"
                    content.sound = .default
                    
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
                        repeats: false
                    )
                    
                    let request = UNNotificationRequest(
                        identifier: "hydration_reminder_\(index)",
                        content: content,
                        trigger: trigger
                    )
                    
                    center.add(request) { error in
                        if let error = error {
                            print("[DEBUG] Failed to schedule reminder \(index):", error)
                        } else {
                            print("[DEBUG] Scheduled reminder \(index) at:", reminderDate)
                        }
                    }
                } else {
                    print("[DEBUG] Skipped reminder \(index) at \(reminderDate) — outside 10AM-11PM.")
                }
            }
        }
    }
}
