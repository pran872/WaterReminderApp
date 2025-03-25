import SwiftUI

@main
struct LifeApp: App {
    init() {
        ReminderManager.shared.requestPermission()
        ReminderManager.shared.scheduleDailyReminders()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
