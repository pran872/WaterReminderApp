import Foundation

enum HydrationConstants {
    static let intervals: [Int] = [120, 135, 145, 150, 153] // minutes
    static let baseReminderDelay = 2 // 2 hours = 120 minutes
    static let reminderStartHour = 10  // 10AM
    static let reminderEndHour = 23    // 11PM
}
