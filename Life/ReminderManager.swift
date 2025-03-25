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
        if hour >= 21 {
                print("[DEBUG] It's after 9PM. No reminders will be scheduled tonight.")
                return
        }
        if hour < 8 {
                print("[DEBUG] It's before 8AM. No reminders will be scheduled until 10AM.")
                return
        }
        
        
        let intervals: [Int] = [120, 135, 145, 150, 153] // 2h, +15m, +10m, +5m, +3m
//        let intervals: [Int] = [1, 2, 3, 4, 240] // 2h, +15m, +10m, +5m, +3m
        let titles = [
            "💧 Time to drink water",
            "💧 Gentle Reminder",
            "💧 Still waiting...",
            "💧 It's really time now",
            "💧 Final hydration alert"
        ]
        
        for (index, offset) in intervals.enumerated() {
            if let reminderDate = calendar.date(byAdding: .minute, value: offset, to: date) {
                let reminderHour = calendar.component(.hour, from: reminderDate)
                if reminderHour >= 10 && reminderHour < 23 {
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
