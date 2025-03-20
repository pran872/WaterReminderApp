import SwiftUI
import UserNotifications

struct ContentView: View {
    @AppStorage("waterIntake") private var waterIntake = 0
    @AppStorage("lastUpdatedDate") private var lastUpdatedDate = ""

    let dailyGoal = 10  // Ring will fill up at 10 cups

    var progress: Double {
        return min(Double(waterIntake % dailyGoal) / Double(dailyGoal), 1.0) // Resets after 10 cups
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()  // Pushes content to the center

                // Circular Progress Ring with Tap Gesture
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.2)
                        .foregroundColor(.white)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), center: .center),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut, value: progress)

                    VStack {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .frame(width: 60, height: 80)
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)
                    }
                }
                .frame(width: 250, height: 250)
                .onTapGesture {
                    logWaterIntake()
                }

                // Display only the number of cups
                Text("\(waterIntake)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Spacer()  // Balances spacing
            }
            .onAppear {
                requestNotificationPermission()
                scheduleWaterReminder()
                checkForDailyReset()
            }
        }
    }

    // Log Water Intake
    func logWaterIntake() {
        withAnimation {
            waterIntake += 1
        }
        provideHapticFeedback()
    }

    // Haptic feedback when tapping
    func provideHapticFeedback() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    // Request permission for notifications
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications denied")
            }
        }
    }

    // Schedule notifications every 2 hours
    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Drink Water 💧"
        content.body = "Stay hydrated! Time to drink some water."
        content.sound = .default

//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: true) // Every 2 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 180, repeats: true) // Once afte 10 secs
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // Check if the day has changed and reset water intake
    func checkForDailyReset() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  // Uses the device's timezone (UK if set)

        let today = formatter.string(from: Date())

        // 🛠️ FOR TESTING: Uncomment the line below to always reset on app launch
//         waterIntake = 0

        if lastUpdatedDate != today {
            waterIntake = 0
            lastUpdatedDate = today
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
