import Foundation

enum HydrationConstants {
    static let intervals: [Int] = [120, 135, 145, 150, 153, 156, 158, 159, 160] // minutes
    static let baseReminderDelay = 2 // 2 hours = 120 minutes
    static let defaultReminderStartHour = 10  // 10AM
    static let defaultReminderEndHour = 23    // 11PM
}
