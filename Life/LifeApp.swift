// [NEXT] Need to make it check the time and if it's a new day and no reminders set then set it for that day
// otherwise if I ignore a set of reminders (5) the previous day and never open the app - no more reminders will
// occur - BAD!

import SwiftUI

@main
struct LifeApp: App {
    init() {
        ReminderManager.shared.requestPermission()
//        ReminderManager.shared.scheduleHydrationReminders(from: Date())
//        UserDefaults.standard.set(0, forKey: "lastWaterLogDate")
            }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
