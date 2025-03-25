import SwiftUI

@main
struct LifeApp: App {
    init() {
        ReminderManager.shared.requestPermission()
//        ReminderManager.shared.scheduleHydrationReminders(from: Date())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
