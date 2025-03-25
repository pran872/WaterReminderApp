import SwiftUI

@main
struct LifeApp: App {
    init() {
        ReminderManager.shared.requestPermission()
        ReminderManager.shared.scheduleHydrationReminders(from: Date())
//        UserDefaults.standard.set(0, forKey: "lastWaterLogDate")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
